module SimpleAuth
  module Orm
    module Base
      module InstanceMethods
        def password=(password)
          @password_changed = true
          @password = password
        end

        def password_changed?
          @password_changed == true
        end

        def authorized?
          true
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
          raise SimpleAuth::AbstractMethodError
        end

        # Find user by its credential. If no user is found, raise
        # SimpleAuth::RecordNotFound exception.
        #
        #   User.find_by_credential! "john@doe.com"
        #
        def find_by_credential!(credential)
          raise SimpleAuth::AbstractMethodError
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
end
