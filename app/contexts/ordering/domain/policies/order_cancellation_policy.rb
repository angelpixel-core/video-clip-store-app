module Ordering
  module Domain
    module Policies
      class OrderCancellationPolicy
        def self.allowed?(order)
          (order.placed? || order.confirmed?) && !order.payment_paid? && !order.payment_flow_blocked?
        end
      end
    end
  end
end
