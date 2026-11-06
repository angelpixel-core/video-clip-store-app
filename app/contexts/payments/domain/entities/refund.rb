module Payments
  module Domain
    module Entities
      class Refund
        STATUSES = %w[refund_pending refund_processing refunded failed].freeze

        attr_reader :id, :payment_id, :payment_method_reference_id, :amount_cents,
                    :status, :provider, :provider_reference, :reason, :metadata,
                    :created_at, :updated_at

        def initialize(
          id: nil,
          payment_id: nil,
          payment_method_reference_id: nil,
          amount_cents: 0,
          status: "refund_pending",
          provider: "fake",
          provider_reference: nil,
          reason: nil,
          metadata: {},
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @payment_id = payment_id
          @payment_method_reference_id = payment_method_reference_id
          @amount_cents = amount_cents.to_i
          @status = normalize_status(status)
          @provider = normalize_provider(provider)
          @provider_reference = provider_reference.presence
          @reason = reason
          @metadata = (metadata || {}).to_h
          @created_at = created_at
          @updated_at = updated_at
        end

        def pending?
          status == "refund_pending"
        end

        def processing?
          status == "refund_processing"
        end

        def refunded?
          status == "refunded"
        end

        def failed?
          status == "failed"
        end

        def self.record_class
          Payments::Infrastructure::Persistence::Refund::RefundRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, :refund_pending, :refund_processing, :refunded, :failed,
                   :pending, :processed, :order, :first, :last, to: :record_class
        end

        private

        def normalize_provider(val)
          val.to_s.strip.presence || "fake"
        end

        def normalize_status(val)
          normalized = val.to_s.strip.downcase.presence || "refund_pending"
          normalized = "refund_pending" if normalized == "pending"
          normalized = "refunded" if normalized == "processed"
          normalized
        end
      end
    end
  end
end
