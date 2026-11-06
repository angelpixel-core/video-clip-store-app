module Billing
  module Infrastructure
    module DI
      module Container
        def self.included(klass)
          klass.register("billing.event_consumers.payment_captured", Billing::Infrastructure::Inbound::EventConsumers::PaymentCapturedConsumer)
        end
      end
    end
  end
end
