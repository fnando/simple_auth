require "digest/sha2"

require "rails/railtie"
require "active_support/all"

require "simple_auth/railtie"
require "simple_auth/config"
require "simple_auth/action_controller"
require "simple_auth/orm/base"
require "simple_auth/orm/active_record"
require "simple_auth/orm/mongo_mapper"
require "simple_auth/session"
require "simple_auth/helper"
require "simple_auth/version"

module SimpleAuth
  class RecordNotFound < StandardError; end
  class NotAuthorized < StandardError; end
  class AbstractMethodError < StandardError; end
end
