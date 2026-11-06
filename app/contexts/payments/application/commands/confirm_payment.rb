module Payments
  module Application
    module Commands
      class ConfirmPayment
        def self.call(payment:, provider_reference: nil)
          new(payment:, provider_reference:).call
        end

        def initialize(payment:, provider_reference: nil)
          @payment = payment
          @provider_reference = provider_reference
        end

        def call
          CapturePayment.call(payment: payment, provider_reference: provider_reference)
        end

        private

        attr_reader :payment, :provider_reference
      end
    end
  end
end
