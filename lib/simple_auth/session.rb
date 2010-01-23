module SimpleAuth
  class Session
    attr_accessor :credential
    attr_accessor :password
    attr_accessor :model
    attr_accessor :controller
    attr_accessor :record
    attr_accessor :errors

    class Errors
      attr_accessor :errors

      def add_to_base(message)
        @errors << message
      end

      def initialize
        @errors = []
      end

      def on(attr_name)
        nil
      end

      def full_messages
        @errors
      end

      def empty?
        @errors.empty?
      end
    end

    def self.find
      session = new
      session.record = session.model.find_by_id(session.controller.session[:record_id])

      if session.record
        session
      else
        nil
      end
    end

    def self.create(options = {})
      returning new(options) do |session|
        session.save
      end
    end

    def self.create!(options = {})
      returning new(options) do |session|
        session.save!
      end
    end

    def self.destroy!
      controller = SimpleAuth::Config.controller
      controller.session[:record_id] = nil
      controller.instance_variable_set("@current_user", nil)
      controller.instance_variable_set("@current_session", nil)
      true
    end

    def initialize(options = {})
      options ||= {}

      @credential = options[:credential]
      @password = options[:password]
      @controller = SimpleAuth::Config.controller
      @model = SimpleAuth::Config.model_class
      @errors = Errors.new
    end

    def new_record?
      record.nil?
    end

    def valid?
      if record
        true
      else
        errors.add_to_base I18n.translate("simple_auth.sessions.invalid_credentials")
        false
      end
    end

    def record
      @record ||= model.authenticate(credential, password)
    end

    def save
      if valid?
        controller.send(:reset_session) if SimpleAuth::Config.reset_session
        controller.session[:record_id] = record.id
      end

      controller.session[:record_id] != nil
    end

    def save!
      if valid?
        save
      else
        raise SimpleAuth::NotAuthorized
      end
    end

    def destroy
      @record = nil
      @credential = nil
      @password = nil
      self.class.destroy!
    end
  end
end
