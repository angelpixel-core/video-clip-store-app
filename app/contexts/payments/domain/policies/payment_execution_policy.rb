module Payments
  module Domain
    module Policies
      class PaymentExecutionPolicy
        def self.can_execute?(payment)
          payment.present? && payment.active?
        end
      end
    end
  end
end
