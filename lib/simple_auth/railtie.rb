module SimpleAuth
  class Railtie < Rails::Railtie
    generators do
      require "simple_auth/generator"
    end

    config.after_initialize do
      ActiveSupport.on_load(:action_controller) do
        include SimpleAuth::ActionController
        helper SimpleAuth::Helper
        prepend_before_filter :activate_simple_auth
        helper_method :current_user, :current_session, :logged_in?
      end

      ActiveSupport.on_load(:active_record) do
        include SimpleAuth::ActiveRecord
      end
    end

    initializer "simple_auth.initialize" do |app|
      ::I18n.load_path += Dir[File.dirname(__FILE__) + "/../../config/locales/*.yml"]
    end
  end
end
