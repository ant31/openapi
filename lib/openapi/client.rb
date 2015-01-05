require 'net/https'
require 'time'
require 'base64'
require 'oauth2'

require File.join(File.dirname(__FILE__), 'response')

module OpenAPI
  begin
    require 'system_timer'
    Timer = SystemTimer
  rescue LoadError
    require 'timeout'
    Timer = Timeout
  end

  module ClassMethods
    attr_accessor :application_key, :application_secret, :max_retry,
    :logger, :request_timeout, :client_id, :site, :auth_token, :api_version, :api_methods, :use_ssl, :cache

    def api_methods
      @api_methods ||= []
    end

    def create_method(name, callback)
      metaclass.instance_eval do
        define_method(name, callback)
      end
    end

    def call_api(request)
      Timer.timeout(request_timeout) do
        start_time = Time.now
        response = http_client.request(request)
        log_request_and_response(request, response, Time.now - start_time)

        response = OpenAPI::Response.wrap(response)
        return response
      end
    rescue Timeout::Error
      unless logger.nil?
        logger.error "OpenAPI request timed out after #{request_timeout} seconds: [#{request.path} #{request.body}]"
      end
      OpenAPI::Response.wrap(nil, :body => {:error => 'Request timeout'}, :code => '503')
    end

    def build_path(path, params=nil)
      uri = URI("/#{api_v}/#{path.gsub(/:client_id/, client_id)}")
      if params != nil
        uri.query = URI.encode_www_form(params)
      end
      return uri
    end

    def auth_token
      raise NotImplementedError
    end

    def do_request(http_method, path, options = {}, retried=0)
      path = build_path(path, options[:params])

      klass = Net::HTTP.const_get(http_method.to_s.capitalize)
      request = klass.new(path.to_s)
      request.add_field "Content-Type", options[:content_type] || "application/json"
      if !auth_token.nil? && options[:skip_auth] != true
        request.add_field "Authorization", (options[:access_token] || auth_token.token)
      end
      request.add_field "Accept", options[:accept] || "application/json"
      #Authorization: Basic dWJ1ZHUtYXBpOmZHWTI4aypOZTh2YzA=
      #Authorization: Bearer
      request.body = options[:body] if options[:body]
      response = call_api(request)
      return response
    end

    def verify_configuration_values(*symbols)
      absent_values = symbols.select{|symbol| instance_variable_get("@#{symbol}").nil? }
      raise("Must configure #{absent_values.join(", ")} before making this request.") unless absent_values.empty?
    end

    def site
      @site
    end

    def http_client
      Net::HTTP.new(site, 443).tap{|http| http.use_ssl = true}
    end

    def log_request_and_response(request, response, time)
      return if logger.nil?
      time = (time * 1000).to_i
      http_method = request.class.to_s.split('::')[-1]
      logger.info "#{self.class.name} (#{time}ms): [#{http_method} #{request.path} #{request.to_hash}, #{request.body}], [#{response.code}, #{response.body}]"
      logger.flush if logger.respond_to?(:flush)
    end

    def format_time(time)
      time = Time.parse(time) if time.is_a?(String)
      time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def request_timeout
      @request_timeout || 5.0
    end

    def api_v()
      @api_version || "v1"
    end

    def logger
      @logger ||= OpenAPI.logger
    end

  end

  class << self
    include ClassMethods
  end

  class Client
    class << self
      include ClassMethods
    end
    include ClassMethods

    def initialize(options={})
      @api_version = options[:api_version] || OpenAPI.api_version
      @logger = options[:logger] || OpenAPI.logger
      @application_key = options[:application_key] || OpenAPI.application_key
      @application_secret = options[:application_secret] || OpenAPI.application_secret
      @site = options[:site] || OpenAPI.site
      @request_timeout = options[:request_timeout] || OpenAPI.request_timeout || 5
      @max_retry = options[:max_retry] || OpenAPI.max_retry || 2
    end
  end
end
