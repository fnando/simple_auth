require "digest/sha2"
require "simple_auth/railtie"
require "simple_auth/config"
require "simple_auth/action_controller"
require "simple_auth/active_record"
require "simple_auth/session"
require "simple_auth/helper"
require "simple_auth/version"

module SimpleAuth
  class NotAuthorized < Exception; end
end
