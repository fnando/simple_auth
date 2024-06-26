# frozen_string_literal: true

module SimpleAuth
  class Session
    def self.record_not_found_exceptions
      @record_not_found_exceptions ||= []
    end

    def self.create(**)
      new(**)
    end

    def initialize(scope:, session:, record: nil)
      @scope = scope
      @session = session
      self.record = record if record
    end

    def record=(record)
      @session[record_key] = record ? record.to_gid.to_s : nil
      @record = record
    end

    def record
      return unless record_id_from_session

      @record ||= GlobalID::Locator.locate(record_id_from_session)
    rescue *Session.record_not_found_exceptions
      nil
    end

    def record_key
      :"#{@scope}_id"
    end

    def record_id_from_session
      @session[record_key]
    end

    def valid?
      record.present?
    end
  end
end
