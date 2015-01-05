require 'active_support'
module OpenAPI
  module Route
    # def static
    #   match '/track_coupon/:source/:id' => 'mobile_banner#track_coupon', :as_ => :track_coupon, :defaults => { :format => 'png' }
    module ClassMethods

      def check_params(path, params, model=nil)
        keys = {}
        parts = path.split("/")
        parts.each do |part|
          if part.start_with?(":")
            keys[part] = true
            name = part[1..-1].to_sym
            if !params.has_key?(name)
              if model.respond_to?(name)
                params[name] = model.send name
              else
                # @todo raise real errors
                raise "Missing params: set '#{part}' to complete '#{path}' request"
              end
            end
          end
        end
        return keys
      end



      def create_proc(klass, kmethod, path, options, client=nil)
        proc = Proc.new() do |arg1=nil, arg2={}|
          if client == nil
            client = OpenAPI::Route.get_client()
          end
          model = nil
          if options.has_key?(:body) && !arg1.instance_of?(Hash)
            model = arg1
            params = arg2
            if !model.instance_of?(options[:body])
              raise "Expected #{options[:body]} class, got #{model.class} instead"
            end
          elsif arg1.instance_of?(Hash) && options.has_key?(:body) && arg1[:body] == nil
            raise "No body provided"
          else
            if arg1 == nil || arg1.instance_of?(Hash)
              params = arg1 || {}
            end
          end

          if model != nil
            to_json_options = nil
            if params.has_key?(:to_json)
              to_json_options = params[:to_json]
            elsif options.has_key?(:to_json)
              to_json_options = options[:to_json]
            end
            if to_json_options
              params[:body] = model.send :to_json, to_json_options
            else
              params[:body] = model.to_json
            end
          end

          if params.has_key?(:display_help) && params[:display_help]
            return options
          end

          parameters = params[:params] || {}
          params.each do |key,v|
            if options.has_key?(:params) && options[:params].has_key?(key)
              parameters[key] = v
            end
          end
          params[:params] = parameters

          if options.has_key?(:extra)
            options[:extra].each do |k,v|
              if !params.has_key?(k)
                params[k] = v
              end
            end
          end

          OpenAPI.logger.debug params
          if not params.has_key?(:client_id)
            params[:client_id] = client.client_id
          end
          OpenAPI::Route.check_params(path, params, model)

          #1. soon.wrap = do_request opts[:body] => postjson
          new_path = path.clone()
          params.each do |key, v|
            r = Regexp.compile(":" + key.to_s)
            new_path.gsub!(r, v.to_s)
          end
          OpenAPI.logger.debug(new_path)
          response = client.do_request(options[:via], new_path, params)
          #2. callback
          return klass.send kmethod.to_s.to_sym, response, params
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
