# frozen_string_literal: true

module SimpleAuth
  module ActionController
    extend ActiveSupport::Concern

    included do
      install_simple_auth_scopes
    end

    module ClassMethods
      def install_simple_auth_scopes
        SimpleAuth.config.scopes.each do |scope|
          install_simple_auth_scope(scope)
          helper_method "current_#{scope}", "#{scope}_logged_in?"
        end
      end

      def install_simple_auth_scope(scope)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # def user_session
          #   @user_session ||= Session.create(scope: :user, session: session)
          # end
          def #{scope}_session
            @#{scope}_session ||= Session.create(scope: :#{scope}, session: session)
          end

          # def current_user
          #   user_session.record
          # end
          def current_#{scope}
            #{scope}_session.record
          end

          # def user_logged_in?
          #   current_user.present?
          # end
          def #{scope}_logged_in?
            current_#{scope}.present?
          end
        RUBY

        define_method "authorized_#{scope}?" do
          true
        end

        define_method "require_logged_#{scope}" do
          simple_auth_require_logged_scope(scope)
        end

        define_method "redirect_logged_#{scope}" do
          simple_auth_redirect_logged_scope(scope)
        end
      end
    end

    private def simple_auth
      @simple_auth ||= SimpleAuth.config
    end

    private def return_to(url)
      session.delete(:return_to) || url
    end

    private def simple_auth_require_logged_scope(scope)
      authorization = RequireLoginAction.new(self, scope)

      return if authorization.valid?

      reset_session
      flash[simple_auth.flash_message_key] = authorization.error_message
      session[:return_to] = request.fullpath if request.get?
      redirect_to instance_eval(&simple_auth.login_url)
    end

    private def simple_auth_redirect_logged_scope(scope)
      scope_session = send("#{scope}_session")
      return unless scope_session.valid?

      redirect_to instance_eval(&simple_auth.logged_url)
    end
  end
end
