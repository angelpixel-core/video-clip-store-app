module Capacity
  module Adapters
    module Inbound
      module ScheduledJobs
        class CheckCapacityJob
          def perform(offer_id)
            offer = Catalog::Domain::Repositories::OfferRepository.find_by_id(offer_id)
            Capacity::Application::Queries::CheckCapacity.call(offer: offer)
          end
        end
      end
    end
  end
end
