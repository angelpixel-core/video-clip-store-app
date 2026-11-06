module Payments
  module Domain
    module Entities
      class PaymentWebhookEvent
        STATUSES = %w[received processed failed].freeze

        attr_reader :id, :provider, :provider_event_id, :event_type, :status,
                    :payload, :signature, :payment_id, :project_id, :received_at,
                    :processed_at, :processing_attempts_count, :last_attempted_at,
                    :last_failure_at, :last_failure_message, :failure_reason_code,
                    :error_message, :created_at, :updated_at

        def initialize(
          id: nil,
          provider: "fake",
          provider_event_id: nil,
          event_type: nil,
          status: "received",
          payload: {},
          signature: nil,
          payment_id: nil,
          project_id: nil,
          received_at: nil,
          processed_at: nil,
          processing_attempts_count: 0,
          last_attempted_at: nil,
          last_failure_at: nil,
          last_failure_message: nil,
          failure_reason_code: nil,
          error_message: nil,
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @provider = provider.to_s.presence || "fake"
          @provider_event_id = provider_event_id
          @event_type = event_type
          @status = status.to_s.presence || "received"
          @payload = (payload || {}).to_h
          @signature = signature
          @payment_id = payment_id
          @project_id = project_id
          @received_at = received_at || Time.current
          @processed_at = processed_at
          @processing_attempts_count = processing_attempts_count.to_i
          @last_attempted_at = last_attempted_at
          @last_failure_at = last_failure_at
          @last_failure_message = last_failure_message
          @failure_reason_code = failure_reason_code
          @error_message = error_message
          @created_at = created_at
          @updated_at = updated_at
        end

        def references_payment?(payment)
          data = payload.to_h.fetch("data", {}).to_h
          target_id = payment.respond_to?(:id) ? payment.id.to_s : nil
          target_ref = payment.respond_to?(:provider_reference) ? payment.provider_reference.to_s : nil
          data["payment_id"].to_s == target_id || data["provider_reference"].to_s == target_ref
        end

        def applied?
          status == "processed"
        end

        def self.record_class
          Payments::Infrastructure::Persistence::Webhook::Event::PaymentWebhookEventRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :find_or_initialize_by, :where,
                   :count, :create, :create!, :all, :order, :first, :last, to: :record_class
        end
      end
    end
  end
end
