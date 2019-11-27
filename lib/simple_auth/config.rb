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

    def install_helpers!
      ::ActionController::Base.include SimpleAuth::ActionController
    end
  end
end
