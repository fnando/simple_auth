# Use this file to setup SimpleAuth.
SimpleAuth.setup do |config|
  # Set which attributes will be used for authentication.
  config.credentials = [:email, :login]

  # Set the login url.
  config.login_url = proc { login_path }

  # Logged users will be redirect to this url
  # when +redirect_logged_user+ helper is used.
  config.logged_url = proc { root_path }

  # Automatically remove all session values that start with your model name.
  #
  # When an existing session is destroyed or a new session is created,
  # SimpleAuth will remove the record id stored as <tt>#{SimpleAuth::Config.model}</tt>.
  #
  # Additionally, you can enable this option to remove any other key composed by
  # <tt>#{SimpleAuth::Config.model}_*</tt>.
  #
  # config.wipeout_session = true
end
