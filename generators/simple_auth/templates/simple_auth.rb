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

  # Set the User model that should be used
  config.model = :user

  # Set the login url
  config.redirect_to = proc { login_path }
end
