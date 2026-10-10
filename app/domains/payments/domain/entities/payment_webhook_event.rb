module Payments
  module Domain
    module Entities
        class PaymentWebhookEvent < ApplicationRecord
        STATUSES = %w[received processed failed].freeze

        belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment", optional: true
        belongs_to :project, class_name: "Order", foreign_key: :project_id, optional: true
        has_many :processing_attempts, class_name: "Payments::Domain::Entities::PaymentWebhookEventAttempt", dependent: :destroy

        before_validation :normalize_provider
        before_validation :normalize_status
        before_validation :normalize_payload
        before_validation :stamp_received_at, on: :create

        validates :provider, presence: true
        validates :provider_event_id, presence: true, uniqueness: { scope: :provider }
        validates :event_type, presence: true
        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :payload, presence: true
        validates :received_at, presence: true

        def references_payment?(payment)
          data = payload.to_h.fetch("data", {}).to_h
          data["payment_id"].to_s == payment.id.to_s || data["provider_reference"].to_s == payment.provider_reference.to_s
        end

        def applied?
          status == "processed"
        end

        def record_processing_attempt!
          now = Time.current
          attempt = processing_attempts.create!(
            attempt_number: processing_attempts.count + 1,
            status: :started,
            started_at: now
          )
          increment!(:processing_attempts_count)
          update!(last_attempted_at: now)
          attempt
        end

        def mark_failed!(message, attempt: nil, failure_reason_code: nil)
          attempt&.fail!(message)
          update!(
            status: :failed,
            error_message: message,
            last_failure_at: Time.current,
            last_failure_message: message,
            failure_reason_code: failure_reason_code.presence || self.failure_reason_code
          )
        end

        def mark_processed!(attempt: nil)
          attempt&.succeed!
          update!(status: :processed, processed_at: Time.current, error_message: nil)
        end

        def synchronize_payment_context!(payment)
          return unless payment.present?

          update!(payment: payment, project: payment.project) if self.payment_id != payment.id || self.project_id != payment.project_id
        end

        def order
          project
        end

        def order=(value)
          self.project = value
        end

        private

        def normalize_provider
          self.provider = provider.to_s.strip.downcase
        end

        def normalize_status
          self.status = status.to_s.presence || "received"
        end

        def normalize_payload
          self.payload = (payload || {}).to_h
        end

        def stamp_received_at
          self.received_at ||= Time.current
        end
        end
    end
  end
end
