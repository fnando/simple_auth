module SimpleAuth
  module ActiveRecord
    def self.included(base)
      base.class_eval { extend Macro }
    end

    module Macro
      # Set virtual attributes, callbacks and validations.
      # Is called automatically after setting up configuration with
      # `SimpleAuth.setup {|config| config.model = :user}`.
      #
      #   class User < ActiveRecord::Base
      #     authentication
      #   end
      #
      # Can set configuration when a block is provided.
      #
      #   class User < ActiveRecord::Base
      #     authentication do |config|
      #       config.credentials = ["email"]
      #     end
      #   end
      #
      def authentication(&block)
        SimpleAuth.setup(&block) if block_given?
        SimpleAuth::Config.model ||= name.underscore.to_sym

        return if respond_to?(:authenticate)

        attr_reader :password
        attr_accessor :password_confirmation

        include SimpleAuth::ActiveRecord::InstanceMethods
        extend  SimpleAuth::ActiveRecord::ClassMethods

        before_save :encrypt_password, :if => :validate_password?
        after_save  :erase_password

        validates_presence_of     :password,              :if => :validate_password?
        validates_length_of       :password,              :if => :validate_password?, :minimum => 4, :allow_blank => true
        validates_presence_of     :password_confirmation, :if => :validate_password?
        validates_confirmation_of :password,              :if => :validate_password?
      end
    end

    module InstanceMethods
      def password=(password)
        @password_changed = true
        @password = password
      end

      def password_changed?
        @password_changed == true
      end

      private
      def encrypt_password
        self.password_salt = SimpleAuth::Config.salt.call(self)
        self.password_hash = SimpleAuth::Config.crypter.call(password, password_salt)
      end

      def erase_password
        self.password = nil
        self.password_confirmation = nil

        # Mark password as unchanged after erasing passwords,
        # or it will be marked as changed anyway
        @password_changed = false
      end

      def validate_password?
        new_record? || password_changed?
      end
    end

    module ClassMethods
      # Find user by its credential.
      #
      #   User.find_by_credential "john@doe.com" # using e-mail
      #   User.find_by_credential "john" # using username
      #
      def find_by_credential(credential)
        # Build a hash that will be passed to the finder
        options = {:conditions => [[], {}]}

        # Iterate each attribute that should be used as credential
        # and set it to the finder conditions hash
        SimpleAuth::Config.credentials.each do |attr_name|
          options[:conditions][0] << "#{attr_name} = :#{attr_name}"
          options[:conditions][1][attr_name] = credential
        end

        # Join the attributes in OR query
        options[:conditions][0] = options[:conditions][0].join(" OR ")

        # Find the record using the conditions we built
        SimpleAuth::Config.model_class.first(options)
      end

      # Find user by its credential. If no user is found, raise
      # ActiveRecord::RecordNotFound exception.
      #
      #   User.find_by_credential! "john@doe.com"
      #
      def find_by_credential!(credential)
        record = find_by_credential(credential)
        raise ::ActiveRecord::RecordNotFound, "couldn't find #{SimpleAuth::Config.model} using #{credential.inspect} as credential" unless record
        record
      end

      # Receive a credential and a password and try to authenticate the specified user.
      # If the credential is valid, then an user is returned; otherwise nil is returned.
      #
      #   User.authenticate "johndoe", "test"
      #   User.authenticate "john@doe.com", "test"
      #
      def authenticate(credential, password)
        record = find_by_credential(credential)

        # If no record has been found
        return nil unless record

        # Compare password
        return nil unless record.password_hash == SimpleAuth::Config.crypter.call(password, record.password_salt)

        # Yay! Everything matched so return record.
        record
      end
    end
  end
end
