module Payments
  module Domain
    module Events
      class PaymentRequiresAction
        attr_reader :payment, :occurred_at, :metadata

        def initialize(payment:, occurred_at: Time.current, metadata: {})
          @payment = payment
          @occurred_at = occurred_at
          @metadata = metadata.to_h
        end
      end
    end
  end
end
