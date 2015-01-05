module OpenAPI
  class Handler
    def self.failed(response)
      #      error =  OpenAPI::Models::Error.new().from_json(response.raw)
      model =  OpenAPI::Handlers::Response.wrap(response.raw, response)
      return model
    end
  end
end

dir = File.dirname(__FILE__)
handlers_dir = File.join(dir, "handlers")
Dir[handlers_dir + "/*.rb"].each {|file| require  file }
