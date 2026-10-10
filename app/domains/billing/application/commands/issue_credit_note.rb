module Billing
  module Application
    module Commands
      class IssueCreditNote
        def self.call(invoice_number:, amount_cents:, reason:)
          new(invoice_number:, amount_cents:, reason:).call
        end

        def initialize(invoice_number:, amount_cents:, reason:)
          @invoice_number = invoice_number.to_s.strip
          @amount_cents = amount_cents.to_i
          @reason = reason.to_s.strip
        end

        def call
          credit_note = Billing::Domain::Entities::CreditNote.new(
            number: "CN-#{SecureRandom.hex(4).upcase}",
            invoice_number: invoice_number,
            amount_cents: amount_cents,
            reason: reason
          )

          Core::Result::Success.(data: { credit_note: credit_note })
        end

        private

        attr_reader :invoice_number, :amount_cents, :reason
      end
    end
  end
end
