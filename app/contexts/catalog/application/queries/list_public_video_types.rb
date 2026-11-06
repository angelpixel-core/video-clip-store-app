module Catalog
  module Application
    module Queries
        class ListPublicVideoTypes
          def self.call(account:)
            video_types = Catalog::Domain::Repositories::OfferRepository.public_variants.select do |offer_variant|
              Catalog::Domain::Policies::VisibilityPolicy.visible_to?(account, offer_variant)
            end

            Core::Result::Success.(data: { video_types: video_types })
          end
        end
    end
  end
end
