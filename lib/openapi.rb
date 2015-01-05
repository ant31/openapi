require "active_support/core_ext/numeric/time"
require 'openapi/utils'
require 'openapi/client'
require 'openapi/response'
require 'openapi/metaclass'
require 'openapi/handlers'
require 'openapi/route'
require 'openapi/models'
require 'openapi/auth_token'


## MOVE TO APP ""
require 'logger'
OpenAPI.logger = Logger.new(STDOUT)
OpenAPI.request_timeout = 5 # default
OpenAPI.max_retry=2
OpenAPI.cache = nil
