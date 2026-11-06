module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        module Rules
          class AvailabilityRule
            def evaluate(offerable, quantity:, context: {})
              requested_units = quantity.to_i
              available_units = Capacity::Domain::Policies::CapacityCalculationPolicy.available_units_for(offerable)
              available = requested_units.positive? && available_units >= requested_units

              Catalog::Domain::ValueObjects::Availability.new(
                available: available,
                reason: available ? nil : :insufficient_capacity,
                details: {
                  requested_units: requested_units,
                  available_units: available_units,
                  context: context
                }
              )
            end
          end
        end
      end
    end
  end
end
