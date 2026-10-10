module Catalog
  module Application
    module DTO
      VideoTypeDTO = Struct.new(:id, :name, :description, :price_cents, :output_format, keyword_init: true) do
        def self.from_video_type(video_type)
          from_offer_variant(video_type)
        end

        def self.from_offer_variant(offer_variant)
          new(
            id: offer_variant.id,
            name: offer_variant.name,
            description: offer_variant.description,
            price_cents: offer_variant.price_cents,
            output_format: offer_variant.output_format
          )
        end
      end
    end
  end
end
