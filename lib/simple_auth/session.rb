# frozen_string_literal: true

module SimpleAuth
  class Session
    def self.create(**kwargs)
      new(**kwargs)
    end

    def initialize(scope:, session:, record: nil)
      @scope = scope
      @session = session
      self.record = record if record
    end

    def record=(record)
      @session[record_key] = record.try(:id)
      @record = record
    end

    def record
      return unless record_id_from_session

      @record ||= record_class
                  .find_by_id(record_id_from_session)
    end

    def record_class
      @record_class ||= Object.const_get(:"#{@scope.to_s.camelize}")
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
