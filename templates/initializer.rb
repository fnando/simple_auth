# Use this file to setup SimpleAuth.
SimpleAuth.setup do |config|
  # Generate the password hash. The specified block should expected
  # the plain password and the password hash as block parameters.
  # config.crypter = proc {|password, salt| Digest::SHA256.hexdigest("#{password}--#{salt}") }

  # Generate the password salt. The specified block should expect
  # the ActiveRecord instance as block parameter.
  # config.salt = proc {|r| Digest::SHA256.hexdigest("#{Time.now.to_s}--#{r.email}")}

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
