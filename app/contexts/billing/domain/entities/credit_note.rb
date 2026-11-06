module Billing
  module Domain
    module Entities
      class CreditNote
        attr_reader :number, :invoice_number, :amount_cents, :reason, :issued_at

        def initialize(number:, invoice_number:, amount_cents:, reason:, issued_at: Time.current)
          @number = number.to_s.strip
          @invoice_number = invoice_number.to_s.strip
          @amount_cents = amount_cents.to_i
          @reason = reason.to_s.strip
          @issued_at = issued_at
        end

        def to_h
          {
            number: number,
            invoice_number: invoice_number,
            amount_cents: amount_cents,
            reason: reason,
            issued_at: issued_at
          }
        end
      end
    end
  end
end
