module OpenAPI
  module Handlers
    class Hashie < OpenAPI::Handler
      class << self
        def hashie(snake_name, response, options)
          return self.failed(response) if not response.success?
          klass_name = snake_name.camelize
          hash = JSON.parse(response.raw)
          resp = Payplug::Model::Response.new(hash)
          return OpenAPI::Handlers::Response.wrap(resp, response)
        end
      end
    end
  end
end
