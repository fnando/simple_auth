# frozen_string_literal: true

module SimpleAuth
  class Config
    # Set which scopes will be activated.
    # By default it enables `user` and `admin`.
    attr_accessor :scopes

    # Set the login url.
    # This will be used to redirect unlogged users to the login page.
    # Default to `login_path`.
    attr_accessor :login_url

    # Set the logged url.
    # This will be used to redirect logged users to the dashboard page.
    # Default to `dashboard_path`.
    attr_accessor :logged_url

    # Set the flash message key.
    # This will be used when setting messages for unlogged/unauthorized users.
    attr_accessor :flash_message_key

    def install_helpers!
      ::ActionController::Base.include SimpleAuth::ActionController
      ::ActionController::API.include SimpleAuth::ActionController::API
    end
  end
end
