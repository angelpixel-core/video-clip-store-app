module Capacity
  module Adapters
    module Persistence
      class ActiveRecordCapacityRepository
        def self.current
          Capacity::Domain::Repositories::CapacityRepository.current
        end
      end
    end
  end
end
