module SimpleAuth
  def self.migrate_passwords!
    require "ostruct"

    generator = OpenStruct.new.extend(ActiveModel::SecurePassword::InstanceMethodsOnActivation)

    Config.model_class.find_each do |record|
      generator.password = record.password_hash

      Config.model_class
        .where(id: record.id)
        .update_all(password_digest: generator.password_digest)
    end
  end

  module ActiveRecord
    module InstanceMethods
      def password=(password)
        @password = SimpleAuth::Config.crypter.call(password, password_salt)
      end

      def password_confirmation=(password)
        @password_confirmation = SimpleAuth::Config.crypter.call(password, password_salt)
      end

      def authenticate(password)
        super SimpleAuth::Config.crypter.call(password, password_salt)
      end
    end
  end
end
