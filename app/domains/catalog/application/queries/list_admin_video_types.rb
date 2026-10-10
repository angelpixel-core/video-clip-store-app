module Catalog
  module Application
    module Queries
        class ListAdminVideoTypes
          def self.call
            Core::Result::Success.(data: { video_types: Catalog::Domain::Repositories::OfferRepository.all_variants })
          end
        end
    end
  end
end
