module Billing
  module Adapters
    module Persistence
      module Invoice
        class InvoiceRecord < ApplicationRecord
          self.table_name = "billing_invoices"

          belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment"
          belongs_to :order, class_name: "Order", foreign_key: :order_id
          has_many :credit_note_records, class_name: "Billing::Adapters::Persistence::Invoice::CreditNoteRecord", foreign_key: :invoice_id, dependent: :destroy
        end
      end
    end
  end
end
