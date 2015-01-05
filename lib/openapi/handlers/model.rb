require 'active_support'
require File.join(File.dirname(__FILE__), '../models')
module OpenAPI
  module Handlers
    class Model < OpenAPI::Handler
      class << self
        def method_missing(method_symbol, *arguments) #:nodoc:
          method_name = method_symbol.to_s
          if method_name =~ /^(\w+)_model$/
            return self.send :construct_model, $1, *arguments
          else
            super
          end
        end

        private

        def construct_model(snake_name, response, options)
          return self.failed(response) if not response.success?
          klass_name = ActiveSupport::Inflector.camelize(snake_name, true)
          klass = OpenAPI::Models.const_get(klass_name)
          model = klass.new.from_json(response.raw)
          model = OpenAPI::Handlers::Response.wrap(model, response)
          return model
        end

      end
    end
  end
end
