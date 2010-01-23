module SimpleAuth
  module ActionController
    module Implementation
      def self.included(base)
        base.prepend_before_filter :activate_simple_auth
        base.helper_method :current_user, :current_session, :logged_in?
      end
    end

    module InstanceMethods
      private
        def current_session
          @current_session ||= SimpleAuth::Session.find
        end

        def current_user
          current_session && current_session.record
        end

        def authorized?
          true
        end

        def logged_in?
          current_user != nil
        end

        def activate_simple_auth
          SimpleAuth::Config.controller = self
        end

        def simple_auth_path(controller, path)
          path ||= SimpleAuth::Config.redirect_to
          path = controller.instance_eval(&path) if path.kind_of?(Proc)
          path
        end
    end

    module ClassMethods
      # Redirect unlogged users to the specified :to path
      #
      #   require_logged_user :to => proc { login_path }
      #   require_logged_user :to => {:controller => "session", :action => "new"}
      #   require_logged_user :only => [:index], :to => login_path
      #   require_logged_user :except => [:public], :to => login_path
      #
      # You can set :to globally:
      #
      #   SimpleAuth::Config.redirect_to = {:controller => "session", :action => "new"}
      #   SimpleAuth::Config.redirect_to = proc { login_path }
      def require_logged_user(options = {})
        before_filter(options.except(:to)) do |c|
          c.instance_eval do
            path = simple_auth_path(c, options[:to])

            unless logged_in? && authorized?
              flash[:warning] = I18n.translate("simple_auth.sessions.need_to_be_logged")
              session[:return_to] = request.request_uri if request.get?
              redirect_to path
            end
          end
        end
      end

      # Redirect logged users to the specified :to path
      #
      #   redirect_logged_user :to => proc { login_path }
      #   redirect_logged_user :to => {:controller => "dashboard"}
      #   redirect_logged_user :only => [:index], :to => login_path
      #   redirect_logged_user :except => [:public], :to => login_path
      def redirect_logged_user(options = {})
        before_filter(options.except(:to)) do |c|
          c.instance_eval do
            path = simple_auth_path(c, options[:to])
            redirect_to path if logged_in?
          end
        end
      end
    end
  end
end
