module SimpleAuth
  class Session
    attr_accessor :credential
    attr_accessor :password
    attr_accessor :model
    attr_accessor :controller
    attr_accessor :record
    attr_accessor :errors

    class Errors # :nodoc:all
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

      def [](attr_name)
        []
      end
    end

    def self.session_key
      "#{SimpleAuth::Config.model.to_s}_id".to_sym
    end

    def self.record_id
      controller && controller.session[session_key]
    end

    def self.backup(&block)
      backup = controller.session.to_hash.reject do |name, value|
        rejected = [:session_id, session_key].include?(name.to_sym) || SimpleAuth::Config.wipeout_session && name.to_s =~ /^#{SimpleAuth::Config.model}_/
        controller.session.delete(name) if rejected
        rejected
      end

      yield

      backup.each do |name, value|
        controller.session[name.to_sym] = value
      end
    end

    def self.find
      return unless controller && record_id
      session = new
      session.record = session.model.find_by_id(record_id)

      if session.record
        session
      else
        nil
      end
    end

    def self.create(options = {})
      new(options).tap do |session|
        session.save
      end
    end

    def self.create!(options = {})
      new(options).tap do |session|
        session.save!
      end
    end

    def self.controller
      SimpleAuth::Config.controller
    end

    def self.destroy!
      [:session_id, session_key].each {|name| controller.session.delete(name) }

      controller.instance_variable_set("@current_user", nil)
      controller.instance_variable_set("@current_session", nil)

      backup { controller.reset_session }

      true
    end

    def self.model_name
      ActiveModel::Name.new(self)
    end

    def initialize(options = {})
      options ||= {}

      @credential = options[:credential]
      @password = options[:password]
      @controller = SimpleAuth::Config.controller
      @model = SimpleAuth::Config.model_class
      @errors = Errors.new
    end

    def to_key
      nil
    end

    def new_record?
      record.nil?
    end

    def persisted?
      !new_record?
    end

    def valid?
      if record && record.authorized?
        true
      else
        errors.add_to_base I18n.translate("simple_auth.sessions.invalid_credentials")
        #self.class.destroy!
        false
      end
    end

    def record
      @record ||= model.authenticate(credential, password)
    end

    def save
      #self.class.destroy! if self.class

      controller.session[self.class.session_key] = record.id if valid?
      controller.session[self.class.session_key] != nil
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
      #self.class.destroy! if self.class
    end
  end
end
