module Payments
  module Domain
    module Policies
      class FailureReasonNormalizer
        CODE_MAP = {
          "Payments::Domain::Errors::DemoTransientFailure" => "demo_transient_failure",
          "ActiveRecord::Deadlocked" => "deadlocked"
        }.freeze

        def self.call(error:, event: nil)
          new(error:, event:).call
        end

        def initialize(error:, event: nil)
          @error = error
          @event = event
        end

        def call
          return normalized_code(event_payload_code) if event_payload_code.present?
          return normalized_code(error_code) if error_code.present?

          normalized_code(CODE_MAP[error.class.name]) || "unknown_error"
        end

        private

        attr_reader :error, :event

        def event_payload_code
          payload = event&.payload.to_h
          payload.fetch("data", {}).to_h["failure_reason_code"].presence || payload["failure_reason_code"].presence
        end

        def error_code
          return error.code if error.respond_to?(:code) && error.code.present?
          return error.failure_reason_code if error.respond_to?(:failure_reason_code) && error.failure_reason_code.present?

          nil
        end

        def normalized_code(value)
          value.to_s.strip.downcase.presence&.tr(".", "_")&.tr("-", "_")
        end
      end
    end
  end
end
