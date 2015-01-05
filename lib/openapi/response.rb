module OpenAPI
  module Response
    module InstanceMethods
      attr_accessor :response, :options, :raw

      def code
        response.code.to_s
      end

      def success?
        !!(code =~ /^2/)
      end
    end

    def self.wrap(response)
      OpenAPI.logger.debug(response.body)
      if !response.to_hash["content-type"].find{|a| a.match /.*json.*/}
        output = response.body
      else
        begin
          output = JSON.parse(response.body || '{}')
        rescue JSON::ParserError => e
          OpenAPI.logger.error(e.message)
          OpenAPI.logger.error(e.backtrace.join("\n"))
          output = {}
        end
      end
      output.extend(OpenAPI::Response::InstanceMethods)
      output.response = response
      output.raw = response.body
      return output
    end
  end
end
