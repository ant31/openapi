require 'hashie'
require "active_support/core_ext/numeric/time"
#require 'dm-serializer/to_json'
require 'openapi/exceptions'
require 'openapi/client'
require 'openapi/response'
require 'openapi/metaclass'
require 'openapi/handlers'
require 'openapi/route'
require 'openapi/auth_token'



## MOVE TO APP ""
require 'logger'
OpenAPI.logger = Logger.new(STDOUT)
OpenAPI.logger.level = 1
OpenAPI.request_timeout = 5 # default
OpenAPI.max_retry=2
OpenAPI.cache = nil
