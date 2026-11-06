module Capacity
  module Domain
    module Policies
      class WorkloadEstimationPolicy
        def self.units_for(_offer, quantity: 1)
          quantity.to_i
        end
      end
    end
  end
end
