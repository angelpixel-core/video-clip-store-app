module Billing
  module Domain
    module Events
      class CreditNoteIssued
        attr_reader :credit_note_number, :invoice_number

        def initialize(credit_note_number:, invoice_number:)
          @credit_note_number = credit_note_number
          @invoice_number = invoice_number
        end
      end
    end
  end
end
