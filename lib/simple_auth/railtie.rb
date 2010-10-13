module SimpleAuth
  class Railtie < Rails::Railtie
    generators do
      require "simple_auth/generator"
    end

    initializer "simple_auth.initialize" do |app|
      ::ActionController::Base.instance_eval do
        include SimpleAuth::ActionController
        helper SimpleAuth::Helper
        prepend_before_filter :activate_simple_auth
        helper_method :current_user, :current_session, :logged_in?
      end

      ::ActiveRecord::Base.instance_eval do
        include SimpleAuth::ActiveRecord
      end

      ::I18n.load_path += Dir[File.dirname(__FILE__) + "/../../config/locales/*.yml"]
    end
  end
end
