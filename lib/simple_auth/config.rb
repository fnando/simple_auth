module SimpleAuth
  # Add a shortcut to Authorization::Config
  def self.setup(&block)
    yield SimpleAuth::Config if block_given?
  end

  class Config
    # Generate the password hash. The specified block should expected
    # the plain password and the password hash as block parameters.
    cattr_accessor :crypter
    @@crypter = proc do |password, salt|
      Digest::SHA256.hexdigest [password, salt].join("--")
    end

    # Generate the password salt. The specified block should expect
    # the ActiveRecord instance as block parameter.
    cattr_accessor :salt
    @@salt = proc do |record|
      Digest::SHA256.hexdigest [Time.to_s, ActiveSupport::SecureRandom.hex(32)].join("--")
    end

    # Set which attributes will be used for authentication.
    cattr_accessor :credentials
    @@credentials = [:email, :login]

    # Set the user model
    cattr_accessor :model
    @@model = :user

    # Set the current controller object
    cattr_accessor :controller
    @@controller = nil

    # Set the login url
    cattr_accessor :redirect_to
    @@redirect_to = proc { login_path }

    # Reset session before saving the user session
    cattr_accessor :reset_session
    @@reset_session = false

    def self.model_class
      model.to_s.classify.constantize
    end
  end
end
