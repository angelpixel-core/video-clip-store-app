module Catalog
  module Application
    module Queries
        class FindVideoType
          def self.call(id:)
            video_type = Catalog::Domain::Repositories::OfferRepository.find_variant_by_id(id)
            return Core::Result::Failure.(message: "Video type not found.", code: :not_found) if video_type.blank?

            Core::Result::Success.(data: { video_type: Catalog::Application::DTO::VideoTypeDTO.from_offer_variant(video_type) })
          end
        end
    end
  end
end
