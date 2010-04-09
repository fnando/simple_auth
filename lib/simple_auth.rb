require "digest/sha2"
require "simple_auth/config"
require "simple_auth/action_controller"
require "simple_auth/active_record"
require "simple_auth/session"
require "simple_auth/helper"
require "simple_auth/version"

module SimpleAuth
  class NotAuthorized < Exception; end
end

::ActiveRecord::Base.send :include, SimpleAuth::ActiveRecord::InstanceMethods
::ActiveRecord::Base.send :extend, SimpleAuth::ActiveRecord::ClassMethods

::ActionController::Base.send :include, SimpleAuth::ActionController::Implementation
::ActionController::Base.send :include, SimpleAuth::ActionController::InstanceMethods
::ActionController::Base.send :extend, SimpleAuth::ActionController::ClassMethods
::ApplicationController.helper SimpleAuth::Helper if defined?(::ApplicationController)

I18n.load_path += Dir[File.dirname(__FILE__) + "/../config/locales/*.yml"]
