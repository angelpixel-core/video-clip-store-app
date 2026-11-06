module Catalog
  module Domain
    module Policies
      class PricingPolicy
        def self.price_for(offer:, quantity: 1)
          offer.price_cents * Catalog::Domain::ValueObjects::SelectionQuantity.new(quantity).to_i
        end
      end
    end
  end
end
