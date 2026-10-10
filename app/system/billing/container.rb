module Billing
  module Container
    def self.included(klass)
      klass.register("billing.event_consumers.payment_captured", Billing::Adapters::Inbound::EventConsumers::PaymentCapturedConsumer)
    end
  end
end
