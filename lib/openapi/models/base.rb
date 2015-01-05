require 'simplemodel'
module OpenAPI
  module Models
    class Base < SimpleModel::Base
      include SimpleModel::Association

      attr_accessor :raw_json

      def initialize(opts={})
        super(opts)
      end


    end
  end
end
