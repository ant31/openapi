require 'simplemodel'
require 'active_model'
$:.unshift(File.dirname(__FILE__))
module OpenAPI
  module Models
    class << self
      attr_accessor :active_record
    end
    autoload :Base, "models/base"
  end
end
