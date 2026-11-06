module Payments
  module Infrastructure
    module Persistence
      module Payment
        class PaymentInvoiceDeliveryIntentRecord < ApplicationRecord
          self.table_name = "payment_invoice_delivery_intents"

          STATUSES = %w[pending sent failed].freeze

          belongs_to :payment, class_name: "Payments::Infrastructure::Persistence::Payment::PaymentRecord"

          after_commit :enqueue_dispatch_job, on: :create

          before_validation :normalize_status
          before_validation :stamp_scheduled_at, on: :create

          validates :status, presence: true, inclusion: { in: STATUSES }
          validates :scheduled_at, presence: true
          validates :payment_id, uniqueness: true

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

          private

          def enqueue_dispatch_job
            Billing::DispatchInvoiceJob.perform_later(id)
          end

          def normalize_status
            self.status = status.to_s.presence || "pending"
          end

          def stamp_scheduled_at
            self.scheduled_at ||= Time.current
          end
        end
      end
    end
  end
end
