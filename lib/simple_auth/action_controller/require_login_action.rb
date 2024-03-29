# frozen_string_literal: true

module SimpleAuth
  module ActionController
    class RequireLoginAction
      DEFAULT_UNLOGGED_IN_MESSAGE = "You must be logged in to access this page."
      DEFAULT_UNAUTHORIZED_MESSAGE =
        "You don't have permission to access this page."

      attr_reader :controller, :scope

      def initialize(controller, scope)
        @controller = controller
        @scope = scope
      end

      def valid?
        valid_session? && authorized?
      end

      def error_message
        return if valid?
        return unauthorized_message unless authorized?

        unlogged_message
      end

      private def valid_session?
        controller.send(:"#{scope}_session").valid?
      end

      private def authorized?
        controller.send(:"authorized_#{scope}?")
      end

      private def unauthorized_message
        translation_for("#{scope}.unauthorized", DEFAULT_UNAUTHORIZED_MESSAGE)
      end

      private def unlogged_message
        translation_for("#{scope}.unlogged_in", DEFAULT_UNLOGGED_IN_MESSAGE)
      end

      private def translation_for(translation_scope, default_message)
        I18n.t(translation_scope, scope: :simple_auth, default: default_message)
      end
    end
  end
end
