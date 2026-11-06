module Payments
  module Application
    module DTO
      PaymentDTO = Struct.new(:id, :status, :amount_cents, :currency, :provider, :provider_reference, keyword_init: true) do
        def self.from_payment(payment)
          new(
            id: payment.id,
            status: payment.status,
            amount_cents: payment.amount_cents,
            currency: payment.currency,
            provider: payment.provider,
            provider_reference: payment.provider_reference
          )
        end
      end
    end
  end
end
