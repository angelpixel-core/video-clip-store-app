module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        module Rules
          class ResourceRule
            def initialize(resource_key:, minimum_units: 1)
              @resource_key = resource_key.to_s
              @minimum_units = minimum_units.to_i
            end

            def evaluate(_offerable, quantity:, context: {})
              resources = context.fetch(:resources, {})
              available_units = resources[resource_key].presence || resources[resource_key.to_sym].presence || resources[resource_key.to_s].presence || 0
              available_units = available_units.to_i
              requested_units = quantity.to_i * minimum_units
              available = requested_units.positive? && available_units >= requested_units

              Catalog::Domain::ValueObjects::Availability.new(
                available: available,
                reason: available ? nil : :resource_unavailable,
                details: {
                  resource_key: resource_key,
                  minimum_units: minimum_units,
                  requested_units: requested_units,
                  available_units: available_units,
                  context: context
                }
              )
            end

            private

            attr_reader :resource_key, :minimum_units
          end
        end
      end
    end
  end
end
