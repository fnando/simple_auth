module SimpleAuth
  # Add a shortcut to SimpleAuth::Config
  def self.setup(&block)
    yield SimpleAuth::Config if block_given?
  end

  class Config
    # Automatically remove all session values that start with your model name.
    #
    # When an existing session is destroyed or a new session is created,
    # SimpleAuth will remove the record id stored as <tt>#{SimpleAuth::Config.model}</tt>.
    #
    # Additionally, you can enable this option to remove any other key composed by
    # <tt>#{SimpleAuth::Config.model}_*</tt>.
    #
    cattr_accessor :wipeout_session
    @@wipeout_session = false

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
    cattr_accessor :login_url
    @@login_url = proc { login_path }

    # Logged users will be redirect to this url
    # when +redirect_logged_user+ helper is used.
    cattr_accessor :logged_url
    @@logged_url = proc { dashboard_path }

    def self.model_class
      model.to_s.classify.constantize
    end
  end
end
