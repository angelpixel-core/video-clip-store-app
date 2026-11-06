module Payments
  module Application
    module Commands
      class ProcessPaymentWebhook
        def self.call(event:)
          new(event:).call
        end

        def initialize(event:)
          @event = event
        end

        def call
          Payments::Adapters::Inbound::Webhooks::Event::Handler.call(event: event)
        end

        private

        attr_reader :event
      end
    end
  end
end
