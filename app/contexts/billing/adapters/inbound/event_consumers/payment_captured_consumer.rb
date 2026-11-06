module Billing
  module Adapters
    module Inbound
      module EventConsumers
        class PaymentCapturedConsumer
          def self.call(event)
            new.call(event)
          end

          def call(event)
            Billing::Application::Commands::IssueInvoice.call(payment: event.payment)
          end
        end
      end
    end
  end
end
