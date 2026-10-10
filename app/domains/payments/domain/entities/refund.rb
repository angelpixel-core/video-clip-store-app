module Payments
  module Domain
    module Entities
      class Refund < ApplicationRecord
        belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment"
        belongs_to :payment_method_reference, class_name: "Payments::Domain::Entities::PaymentMethodReference"

        STATUSES = %w[refund_pending refund_processing refunded failed].freeze

        scope :refund_pending, -> { where(status: "refund_pending") }
        scope :refund_processing, -> { where(status: "refund_processing") }
        scope :refunded, -> { where(status: "refunded") }
        scope :failed, -> { where(status: "failed") }

        scope :pending, -> { refund_pending }
        scope :processed, -> { refunded }

        before_validation :normalize_provider
        before_validation :normalize_status
        after_commit :broadcast_payment_project_status

        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :provider, presence: true
        validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
        validates :provider_reference, uniqueness: true, allow_nil: true
        validate :payment_method_reference_belongs_to_payment

        private

        def normalize_provider
          self.provider = provider.to_s.strip.presence || "fake"
        end

        def normalize_status
          normalized = status.to_s.strip.downcase.presence || "refund_pending"
          normalized = "refund_pending" if normalized == "pending"
          normalized = "refunded" if normalized == "processed"

          self.status = normalized
        end

        def payment_method_reference_belongs_to_payment
          return if payment_method_reference.blank? || payment_method_reference.payment_id == payment_id

          errors.add(:payment_method_reference, "must belong to the same payment")
        end

        def broadcast_payment_project_status
          payment&.project&.broadcast_status_badge!
        end
      end
    end
  end
end
