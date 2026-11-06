module Payments
  module Application
    module Handlers
      class InvoiceBuilder
        def self.call(payment:)
          Billing::Application::Handlers::InvoiceBuilder.call(payment:)
        end

        # TODO(cleanup): Remove this shim once payment invoice generation calls billing directly.
      end
    end
  end
end
