module Catalog
  module Adapters
    module Persistence
      class ActiveRecordOfferRepository
        def self.find_by_id(id)
          Catalog::Domain::Repositories::OfferRepository.find_by_id(id)
        end

        def self.all
          Catalog::Domain::Repositories::OfferRepository.all
        end
      end
    end
  end
end
