module OpenAPI
  module Handlers
    module Response
      module InstanceMethods
        attr_accessor :response

        def code
          response.code
        end

        def success?
          response.success?
        end
      end

      def self.wrap(obj, response)
        obj.extend(OpenAPI::Handlers::Response::InstanceMethods)
        obj.response = response
        return obj
      end
    end
  end
end
