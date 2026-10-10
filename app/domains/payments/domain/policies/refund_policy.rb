module Payments
  module Domain
    module Policies
      class RefundPolicy
        def self.refundable?(payment)
          payment.present? && payment.succeeded?
        end
      end
    end
  end
end
