module Payments
  module Domain
    module Entities
      class PaymentNotificationIntent < ApplicationRecord
        STATUSES = %w[pending sent failed].freeze

        belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment"
        belongs_to :project, class_name: "Order", foreign_key: :project_id

        after_commit :enqueue_dispatch_job, on: :create

        before_validation :normalize_status
        before_validation :normalize_payload
        before_validation :stamp_scheduled_at, on: :create

        validates :event_type, presence: true
        validates :from_status, presence: true
        validates :to_status, presence: true
        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :payload, presence: true
        validates :scheduled_at, presence: true
        validates :payment_id, uniqueness: { scope: :event_type }

        def mark_sent!
          update!(status: :sent, processed_at: Time.current, last_error: nil)
        end

        def mark_failed!(message)
          increment!(:attempts_count)
          update!(status: :failed, last_error: message, processed_at: nil)
        end

        def pending?
          status == "pending"
        end

        def sent?
          status == "sent"
        end

        def failed?
          status == "failed"
        end

        private

        def enqueue_dispatch_job
          Payments::Application::Handlers::DispatchPaymentNotificationJob.perform_later(id)
        end

        def normalize_status
          self.status = status.to_s.presence || "pending"
        end

        def normalize_payload
          self.payload = (payload || {}).to_h
        end

        def order
          project
        end

        def order=(value)
          self.project = value
        end

        def stamp_scheduled_at
          self.scheduled_at ||= Time.current
        end
      end
    end
  end
end
