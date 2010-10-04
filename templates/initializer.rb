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

  # Set the User model that should be used for authentication.
  config.model = :user

  # Set the login url.
  config.login_url = proc { login_path }

  # Logged users will be redirect to this url
  # when +redirect_logged_user+ helper is used.
  config.logged_url = proc { root_path }
end
