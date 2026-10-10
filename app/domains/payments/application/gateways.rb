module Payments
  module Application
    module Gateways
      PROVIDER_KEYS = {
        "fake" => "payments.gateways.fake",
        "stripe" => "payments.gateways.stripe",
        "mercadopago" => "payments.gateways.mercadopago"
      }.freeze

      def self.resolve(provider)
        ::AppContainer[PROVIDER_KEYS.fetch(normalize_provider(provider), PROVIDER_KEYS.fetch("fake"))]
      end

      def self.normalize_provider(provider)
        provider.to_s.strip.downcase.presence || "fake"
      end

      private_class_method :normalize_provider
    end
  end
end
