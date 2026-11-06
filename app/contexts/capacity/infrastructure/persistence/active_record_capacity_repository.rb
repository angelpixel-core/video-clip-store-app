module Capacity
  module Infrastructure
    module Persistence
      class ActiveRecordCapacityRepository
        def self.current
          Capacity::Domain::Repositories::CapacityRepository.current
        end
      end
    end
  end
end
