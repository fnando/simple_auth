# frozen_string_literal: true

module SimpleAuth
  module RoutingMapper
    class Matcher
      attr_reader :scope, :condition

      def initialize(scope:, condition:)
        @scope = scope
        @condition = condition
      end

      def call(request)
        session = Session.create(scope:, session: request.session)
        record = session.record

        record && condition.call(record)
      end
    end

    def authenticate(scope, condition, &block)
      with_options(
        constraints: Matcher.new(scope:, condition:)
      ) do
        instance_eval(&block)
      end
    end
  end
end
