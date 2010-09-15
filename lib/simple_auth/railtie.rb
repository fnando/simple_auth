module SimpleAuth
  class Railtie < Rails::Railtie
    generators do
      require "simple_auth/generator"
    end

    initializer "simple_auth.initialize" do |app|
      ::ActiveRecord::Base.send :include, SimpleAuth::ActiveRecord

      ::ActionController::Base.send :include, SimpleAuth::ActionController::Implementation
      ::ActionController::Base.send :include, SimpleAuth::ActionController::InstanceMethods
      ::ActionController::Base.send :extend, SimpleAuth::ActionController::ClassMethods
      ::ApplicationController.helper SimpleAuth::Helper if defined?(::ApplicationController)

      ::I18n.load_path += Dir[File.dirname(__FILE__) + "/../../config/locales/*.yml"]
    end
  end
end
