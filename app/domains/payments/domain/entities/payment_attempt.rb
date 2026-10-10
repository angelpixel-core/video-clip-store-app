module Payments
  module Domain
    module Entities
      class PaymentAttempt < ApplicationRecord
        belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment"

        STATUSES = %w[pending submitted succeeded failed].freeze

        before_validation :normalize_provider

        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :provider, presence: true
        validates :idempotency_key, presence: true, uniqueness: true
        validates :provider_reference, uniqueness: true, allow_nil: true

        private

        def normalize_provider
          self.provider = provider.to_s.strip.presence || "fake"
        end
      end
    end
  end
end
