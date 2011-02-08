module SimpleAuth
  module Orm
    module MongoMapper
      def self.included(base)
        base.class_eval { extend Macro }
      end

      module Macro
        def authentication(&block)
          SimpleAuth.setup(&block) if block_given?
          SimpleAuth::Config.model ||= name.underscore.to_sym

          return if respond_to?(:authenticate)

          include SimpleAuth::Orm::Base::InstanceMethods
          extend  SimpleAuth::Orm::Base::ClassMethods
          extend  SimpleAuth::Orm::MongoMapper::ClassMethods

          attr_reader :password
          attr_accessor :password_confirmation

          before_save :encrypt_password, :if => :validate_password?
          after_save  :erase_password

          validates_presence_of     :password,              :if => :validate_password?
          validates_length_of       :password,              :if => :validate_password?, :minimum => 4, :allow_blank => true
          validates_presence_of     :password_confirmation, :if => :validate_password?
          validates_confirmation_of :password,              :if => :validate_password?

          key :password_salt, String
          key :password_hash, String
        end
      end

      module ClassMethods
        # Find user by its credential.
        #
        #   User.find_by_credential "john@doe.com" # using e-mail
        #   User.find_by_credential "john" # using username
        #
        def find_by_credential(credential)
          conditions = SimpleAuth::Config.credentials.collect do |attr_name|
            {attr_name => credential}
          end

          SimpleAuth::Config.model_class.where("$or" => conditions).first
        end

        # Find user by its credential. If no user is found, raise
        # SimpleAuth::RecordNotFound exception.
        #
        #   User.find_by_credential! "john@doe.com"
        #
        def find_by_credential!(credential)
          record = find_by_credential(credential)
          raise SimpleAuth::RecordNotFound, "couldn't find #{SimpleAuth::Config.model} using #{credential.inspect} as credential" unless record
          record
        end
      end
    end
  end
end
