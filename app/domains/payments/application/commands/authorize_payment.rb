module Payments
  module Application
    module Commands
      class AuthorizePayment
        def self.call(payment:, provider_reference: nil)
          new(payment:, provider_reference:).call
        end

        def initialize(payment:, provider_reference: nil)
          @payment = payment
          @provider_reference = provider_reference
        end

        def call
          return failure("Payment cannot be authorized.", :invalid_state) unless payment.active?

          payment.update!(
            status: :processing,
            provider_reference: provider_reference.presence || payment.provider_reference
          )

          Core::Result::Success.(data: { payment: payment, event: Payments::Domain::Events::PaymentAuthorized.new(payment: payment) })
        end

        private

        attr_reader :payment, :provider_reference

        def failure(message, code)
          Core::Result::Failure.(message: message, code: code, data: { payment_id: payment.id })
        end
      end
    end
  end
end
