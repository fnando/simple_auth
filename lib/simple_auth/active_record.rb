module SimpleAuth
  module ActiveRecord
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
      # Receive a credential and a password and try to authenticate the specified user.
      # If the credential is valid, then an user is returned; otherwise nil is returned.
      #
      #   User.authenticate "johndoe", "test"
      #   User.authenticate "john@doe.com", "test"
      def authenticate(credential, password)
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
        record = SimpleAuth::Config.model_class.first(options)

        # If no record has been found
        return nil unless record

        # Compare password
        return nil unless record.password_hash == SimpleAuth::Config.crypter.call(password, record.password_salt)

        return record
      end

      # Set virtual attributes, callbacks and acts as a wrapper for
      # SimpleAuth::Config if a block is provided.
      #
      #   class User < ActiveRecord::Base
      #     has_authentication
      #   end
      #
      #   class User < ActiveRecord::Base
      #     has_authentication do |config|
      #       config.credentials = [:email]
      #     end
      #   end
      def has_authentication(&block)
        attr_reader :password
        attr_accessor :password_confirmation

        SimpleAuth.setup(&block)

        before_save :encrypt_password, :if => :validate_password?
        after_save  :erase_password

        validates_presence_of     :password,              :if => :validate_password?
        validates_length_of       :password,              :if => :validate_password?, :minimum => 4, :allow_blank => true
        validates_presence_of     :password_confirmation, :if => :validate_password?
        validates_confirmation_of :password,              :if => :validate_password?
      end
    end
  end
end
