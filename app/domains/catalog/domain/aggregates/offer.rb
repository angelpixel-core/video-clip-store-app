module Catalog
  module Domain
    module Aggregates
      class Offer < ApplicationRecord
        self.table_name = "video_types"

        has_many :video_type_selections, class_name: "VideoTypeSelection", foreign_key: :video_type_id, dependent: :destroy
        has_many :projects, through: :video_type_selections

        validates :name, presence: true, uniqueness: true
        validates :description, presence: true
        validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
        validates :output_format, presence: true

        def offer_name
          Catalog::Domain::ValueObjects::OfferName.new(name)
        end

        def price
          Catalog::Domain::ValueObjects::Price.new(price_cents)
        end
      end
    end
  end
end
