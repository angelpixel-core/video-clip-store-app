module Billing
  module Domain
    module Events
      class InvoicePaid
        attr_reader :invoice_id, :invoice_number

        def initialize(invoice_id:, invoice_number:)
          @invoice_id = invoice_id
          @invoice_number = invoice_number
        end
      end
    end
  end
end
