module Capacity
  module Domain
    module Repositories
      class CapacityRepository
        def self.current
          Capacity::Domain::Aggregates::ProductionCapacity.new(total_units: ENV.fetch("CAPACITY_TOTAL_UNITS", 100))
        end
      end
    end
  end
end
