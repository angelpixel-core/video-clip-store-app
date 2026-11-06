module Payments
  module Infrastructure
    module DI
      module Container
        def self.included(klass)
          klass.register("payments.gateways.fake", Payments::Infrastructure::Outbound::Gateways::Fake)
          klass.register("payments.gateways.stripe", Payments::Infrastructure::Outbound::Gateways::Stripe)
          klass.register("payments.gateways.mercadopago", Payments::Infrastructure::Outbound::Gateways::MercadoPago)
        end
      end
    end
  end
end
