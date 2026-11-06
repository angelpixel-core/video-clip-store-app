require "bigdecimal"

module Billing
  module Domain
    module Policies
      class TaxCalculationPolicy
        DEFAULT_RATE = BigDecimal("0.21")

        def self.call(base_amount_cents:, billing_identity:)
          new(base_amount_cents:, billing_identity:).call
        end

        def initialize(base_amount_cents:, billing_identity:)
          @base_amount_cents = base_amount_cents.to_i
          @billing_identity = billing_identity
        end

        def call
          return 0 unless billing_identity.respond_to?(:argentina?) ? billing_identity.argentina? : true

          (base_amount_cents * DEFAULT_RATE).round
        end

        private

        attr_reader :base_amount_cents, :billing_identity
      end
    end
  end
end
