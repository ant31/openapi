require 'active_support'
require File.join(File.dirname(__FILE__), '../models')
module OpenAPI
  module Handlers
    class Array < OpenAPI::Handler
      class << self


        def method_missing(method_symbol, *arguments) #:nodoc:
          method_name = method_symbol.to_s
          if method_name =~ /^(\w+)_array$/
            return self.send :construct_array, $1, *arguments
          else
            super
          end
        end

        def raw_array(response, options)
          array = []
          response.each do |model_attr|
            array << model_attr
          end
          array = OpenAPI::Handlers::Response.wrap(array, response)
          return array
        end

        private

        def construct_array(snake_name, response, options)
          return self.failed(response) if not response.success?
          array = []
          klass_name = ActiveSupport::Inflector.camelize(snake_name, true)
          klass = OpenAPI::Models.const_get(klass_name)
          response.each do |model_attr|
            array << klass.new.from_json(model_attr.to_json)
          end
          array = OpenAPI::Handlers::Response.wrap(array, response)
          return array
        end

      end
    end
  end
end
