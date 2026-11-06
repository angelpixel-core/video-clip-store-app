module Catalog
  module Domain
    module Entities
      class OfferVariant
        attr_reader :offer, :quantity

        def initialize(offer:, quantity: 1)
          @offer = offer
          @quantity = Catalog::Domain::ValueObjects::SelectionQuantity.new(quantity).to_i
        end

        def subtotal_cents
          offer.price_cents * quantity
        end
      end
    end
  end
end
