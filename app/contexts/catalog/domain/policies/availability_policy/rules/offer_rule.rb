module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        module Rules
          class OfferRule
            def initialize(allowed_offer_ids: nil, allowed_offer_keys: nil)
              @allowed_offer_ids = Array(allowed_offer_ids).compact
              @allowed_offer_keys = Array(allowed_offer_keys).compact.map(&:to_s)
            end

            def evaluate(offerable, quantity:, context: {})
              return availability(true, quantity:, context:) if allowed_offer_ids.empty? && allowed_offer_keys.empty?

              offer = offer_for(offerable)
              offer_id = offer.respond_to?(:id) ? offer.id : nil
              offer_key = offer.respond_to?(:key) ? offer.key.to_s : nil
              allowed = allowed_offer_ids.include?(offer_id) || allowed_offer_keys.include?(offer_key)

              availability(allowed, quantity:, context:, reason: :offer_not_allowed, details: { offer_id: offer_id, offer_key: offer_key })
            end

            private

            attr_reader :allowed_offer_ids, :allowed_offer_keys

            def offer_for(offerable)
              return offerable.offer if offerable.respond_to?(:offer) && offerable.offer.present?

              offerable
            end

            def availability(available, quantity:, context:, reason: nil, details: {})
              Catalog::Domain::ValueObjects::Availability.new(
                available: available,
                reason: available ? nil : reason,
                details: details.merge(quantity: quantity.to_i, context: context)
              )
            end
          end
        end
      end
    end
  end
end
