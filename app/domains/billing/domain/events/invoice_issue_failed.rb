module Billing
  module Domain
    module Events
      class InvoiceIssueFailed
        attr_reader :invoice_number, :message

        def initialize(invoice_number:, message:)
          @invoice_number = invoice_number
          @message = message
        end
      end
    end
  end
end
