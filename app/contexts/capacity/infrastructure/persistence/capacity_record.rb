module Capacity
  module Infrastructure
    module Persistence
      class CapacityRecord
        def self.current
          Capacity::Domain::Repositories::CapacityRepository.current
        end
      end
    end
  end
end
