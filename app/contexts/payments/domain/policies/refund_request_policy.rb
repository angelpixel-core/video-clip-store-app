module Payments
  module Domain
    module Policies
      class RefundRequestPolicy
        def self.allowed?(payment)
          payment.present? && payment.succeeded? && payment.refunds.none?
        end
      end
    end
  end
end
