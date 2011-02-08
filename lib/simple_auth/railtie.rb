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

      ::ActiveRecord::Base.class_eval { include SimpleAuth::Orm::ActiveRecord } if defined?(::ActiveRecord)
    end
  end
end
