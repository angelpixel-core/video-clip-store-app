module Payments
  module Container
    def self.included(klass)
      klass.register("payments.gateways.fake", Payments::Adapters::Outbound::Gateways::Fake)
      klass.register("payments.gateways.stripe", Payments::Adapters::Outbound::Gateways::Stripe)
      klass.register("payments.gateways.mercadopago", Payments::Adapters::Outbound::Gateways::MercadoPago)
    end
  end
end
