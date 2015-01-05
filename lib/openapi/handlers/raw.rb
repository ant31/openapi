require 'active_support'
require File.join(File.dirname(__FILE__), '../models')
module OpenAPI
  module Handlers
    class Raw < OpenAPI::Handler
      class << self

        def text(response, options)
          return self.failed(response) if not response.success?
          return response
        end
      end
    end
  end
end
