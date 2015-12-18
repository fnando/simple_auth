SimpleAuth.setup do |config|
  # Define with scopes will be installed.
  # This can be useful if you want to have separated sessions
  # (e.g. regular user and admin user).
  #
  # To enable both user and admin sessions, you can define the scopes
  # like this:
  #
  # config.scopes = %i[user admin]
  #
  config.scopes = %i[user]

  # Set the login url.
  # This is where users will be redirected to when they're unlogged.
  config.login_url = proc { login_path }

  # Logged users will be redirect to this url
  # when `before_action :redirect_logged_user` filter is used.
  config.logged_url = proc { dashboard_path }

  # Install SimpleAuth helpers to the controllers.
  config.install_helpers!
end
