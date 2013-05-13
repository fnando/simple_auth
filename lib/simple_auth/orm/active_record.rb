module SimpleAuth
  module Orm
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

          include SimpleAuth::Orm::Base::InstanceMethods
          extend  SimpleAuth::Orm::Base::ClassMethods
          extend  SimpleAuth::Orm::ActiveRecord::ClassMethods

          before_save :encrypt_password, :if => :validate_password?
          after_save  :erase_password

          validates_presence_of     :password,              :if => :validate_password?
          validates_length_of       :password,              :if => :validate_password?, :minimum => 4, :allow_blank => true
          validates_presence_of     :password_confirmation, :if => :validate_password?
          validates_confirmation_of :password,              :if => :validate_password?
        end
      end

      module ClassMethods
        # Find user by its credential.
        #
        #   User.find_by_credential "john@doe.com" # using e-mail
        #   User.find_by_credential "john" # using username
        #
        def find_by_credential(credential)
          # Build a array that will be passed to the finder
          options = [[], {}]

          # Iterate each attribute that should be used as credential
          # and set it to the finder conditions hash
          SimpleAuth::Config.credentials.each do |attr_name|
            options[0] << "#{attr_name} = :#{attr_name}"
            options[1][attr_name] = credential
          end

          # Join the attributes in OR query
          options[0] = options[0].join(" OR ")

          # Find the record using the conditions we built
          SimpleAuth::Config.model_class.where(options).first
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
