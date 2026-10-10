module Billing
  module Adapters
    module Persistence
      module Invoice
        class CreditNoteRecord < ApplicationRecord
          self.table_name = "billing_credit_notes"

          belongs_to :invoice_record, class_name: "Billing::Adapters::Persistence::Invoice::InvoiceRecord", foreign_key: :invoice_id
        end
      end
    end
  end
end
