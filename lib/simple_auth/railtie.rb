# frozen_string_literal: true

module SimpleAuth
  class Railtie < Rails::Railtie
    generators do
      require "simple_auth/generator"
    end

    config.after_initialize do
      ActiveSupport.on_load(:active_record) do
        SimpleAuth::Session.record_not_found_exceptions <<
          ActiveRecord::RecordNotFound
      end
    end
  end
end
