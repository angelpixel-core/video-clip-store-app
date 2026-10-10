module Ordering
  module Domain
    module Policies
      class OrderAcceptancePolicy
        def self.allowed?(order)
          order.placed? && order.payment_paid? && !order.payment_flow_blocked?
        end
      end
    end
  end
end
