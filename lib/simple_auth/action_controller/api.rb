# frozen_string_literal: true

module SimpleAuth
  module ActionController
    module API
      extend ActiveSupport::Concern
      include SimpleAuth::ActionController

      included do
        undef_method :simple_auth_redirect_logged_scope
        undef_method :return_to

        SimpleAuth.config.scopes.each do |scope|
          undef_method :"redirect_logged_#{scope}"
        end
      end

      # A stub session so we can persist the record id between different calls
      # to fetch the record.
      private def session
        @session ||= {}
      end

      private def render_unauthorized_access(*)
        render plain: "401 Unauthorized", status: :unauthorized
      end
    end
  end
end
