module Catalog
  module Domain
    module Repositories
      class OfferRepository
        def self.find_by_id(id)
          find_variant_by_id(id)
        end

        def self.all
          all_variants
        end

        def self.public
          public_variants
        end

        def self.find_variant_by_id(id)
          OfferVariant.includes(:offer, :offer_item_type).find_by(id: id)
        end

        def self.all_variants
          OfferVariant.includes(:offer, :offer_item_type).order(:name)
        end

        def self.public_variants
          client = Identity::Domain::Repositories::AccountRepository.find_by_role(:client).first
          all_variants.select { |offer_variant| Catalog::Domain::Policies::VisibilityPolicy.visible_to?(client, offer_variant) }
        end

        def self.all_offers
          Offer.includes(:offer_item_type_assignments, :offer_variants).order(:name)
        end

        def self.find_offer_by_key(key)
          Offer.find_by(key: key)
        end
      end
    end
  end
end
