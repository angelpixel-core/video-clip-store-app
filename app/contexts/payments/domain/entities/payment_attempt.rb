module Payments
  module Domain
    module Entities
      class PaymentAttempt
        STATUSES = %w[pending submitted succeeded failed].freeze

        attr_reader :id, :payment_id, :status, :provider, :idempotency_key,
                    :provider_reference, :created_at, :updated_at

        def initialize(
          id: nil,
          payment_id: nil,
          status: "pending",
          provider: "fake",
          idempotency_key: nil,
          provider_reference: nil,
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @payment_id = payment_id
          @status = status.to_s.presence || "pending"
          @provider = provider.to_s.presence || "fake"
          @idempotency_key = idempotency_key
          @provider_reference = provider_reference.presence
          @created_at = created_at
          @updated_at = updated_at
        end

        def self.record_class
          Payments::Infrastructure::Persistence::Payment::PaymentAttemptRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, to: :record_class
        end
      end
    end
  end
end
