module Payments
  module Domain
    module Entities
      class PaymentWebhookEventAttempt < ApplicationRecord
        STATUSES = %w[started succeeded failed].freeze

        belongs_to :payment_webhook_event, class_name: "Payments::Domain::Entities::PaymentWebhookEvent"

        before_validation :normalize_status
        before_validation :stamp_started_at, on: :create

        validates :attempt_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :started_at, presence: true
        validates :attempt_number, uniqueness: { scope: :payment_webhook_event_id }

        def succeed!
          update!(status: :succeeded, finished_at: Time.current, error_message: nil)
        end

        def fail!(message)
          update!(status: :failed, finished_at: Time.current, error_message: message)
        end

        private

        def normalize_status
          self.status = status.to_s.presence || "started"
        end

        def stamp_started_at
          self.started_at ||= Time.current
        end
      end
    end
  end
end
