require 'active_support'
require 'cgi'
module OpenAPI
  module Route
    # def static
    #   match '/track_coupon/:source/:id' => 'mobile_banner#track_coupon', :as_ => :track_coupon, :defaults => { :format => 'png' }
    module ClassMethods

      def replace_uri_vars(path, params)
        new_path = path.clone()
        parts = path.split("/")
        parts.each do |part|
          if part.start_with?(":")
            key = part[1..-1].to_sym
            if params.has_key?(key)
              new_path.gsub!(Regexp.compile(":" + key.to_s), CGI.escape(params[key].to_s))
              params.delete(key)
            else
              # @todo raise real errors
              raise "Missing params: set '#{part}' to complete '#{path}' request"
            end
          end
        end
        return new_path
      end

      def create_proc(klass, kmethod, urlpath, opts, client=nil)
        proc = Proc.new() do |params: {}, body: nil, headers: {}, path: nil|
          client = OpenAPI::Route.get_client() if client.nil?

          if opts.has_key?(:default)
            opts[:defaults].each do |k,v|
              if !params.has_key?(k)
                params[k] = v
              end
            end
          end

          OpenAPI.logger.debug params

          path = OpenAPI::Route.replace_uri_vars(path || urlpath, params)

          #1. soon.wrap = do_request opts[:body] => postjson
          OpenAPI.logger.debug(path)
          response = client.do_request(opts[:via], path, {params: params, body: body, headers: headers, options: opts[:options] || {}})
          #2. callback
          return klass.send kmethod.to_s.to_sym, response, {params: params, body: body, headers: headers, options: opts[:options] || {}}
        end
        return proc
      end

      def match(path, callback, name, options={:via => :get}, client=nil)
        klass_name, klass_method = callback.split("#")
        klass_name = klass_name.classify
        klass = Object.const_get(klass_name)
        if client == nil
          client = get_client()
        end
        proc = create_proc(klass, klass_method, path, options , client)
        client.api_methods << name
        client.create_method(name.to_s, proc)
        return true
      end

      def get_client
        @client ||= OpenAPI::Client
      end

      def draw(client=nil, &block)
        @client = client
        class_eval &block
      end
    end

    class << self
      include ClassMethods
    end
  end
end
