require File.join(File.dirname(__FILE__), '../handlers')

module OpenAPI
  module Handlers

    class Dummy < OpenAPI::Handler
      class << self
        def titi(id, name)
          puts "id:#{id.to_s[0..10]}, name:#{name}"
        end
      end
    end

    class Campaigns < OpenAPI::Handler
      class << self
        def stats(response, options)
          return response, options
        end
      end
    end

    class Offers < OpenAPI::Handler
      class << self
        def index(response, options)
          return response, options
        end
      end
    end

  end
end
