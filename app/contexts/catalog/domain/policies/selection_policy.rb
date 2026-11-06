module Catalog
  module Domain
    module Policies
      class SelectionPolicy
        def self.allowed?(account, offer, quantity: 1)
          return false unless VisibilityPolicy.visible_to?(account, offer)

          quantity.to_i.positive? && AvailabilityPolicy.available?(offer, quantity: quantity)
        end
      end
    end
  end
end
