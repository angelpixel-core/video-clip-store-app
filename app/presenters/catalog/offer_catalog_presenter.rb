module Catalog
  class OfferCatalogPresenter
    OfferGroup = Struct.new(:offer, :variants, keyword_init: true)

    attr_reader :groups

    def initialize(variants:)
      grouped_variants = variants.group_by(&:offer_id)

      @groups = grouped_variants.sort_by { |_offer_id, offer_variants| [ offer_variants.first.offer.name, offer_variants.first.offer.id ] }.map do |_offer_id, offer_variants|
        offer = offer_variants.first.offer
        OfferGroup.new(offer:, variants: offer_variants.sort_by { |variant| [ variant.position, variant.name ] })
      end
    end

    def count
      groups.sum { |group| group.variants.count }
    end

    def empty?
      groups.empty?
    end

    def empty_state
      "No offers available yet."
    end
  end
end
