module Payments
  module Application
    module Commands
      class RefundPayment
        def self.call(payment:, refund:, gateway: nil)
          new(payment:, refund:, gateway:).call
        end

        def initialize(payment:, refund:, gateway: nil)
          @payment = payment
          @refund = refund
          @gateway = gateway
        end

        def call
          return failure("Payment cannot be refunded.", :not_refundable) unless Payments::Domain::Policies::RefundPolicy.refundable?(payment)
          return failure("Payment method reference missing.", :missing_payment_method) if payment.payment_method_reference.blank?
          return failure("Refund request not found.", :not_found) unless refund.present?

          provider_result = payment_gateway_for(payment).refund(payment: payment, refund: refund)
          return handle_provider_failure(provider_result) if provider_result.failure?

          refund.update!(
            status: :refund_processing,
            provider_reference: provider_result.data.fetch(:provider_reference),
            reason: refund.reason
          )

          Core::Result::Success.(data: { payment: payment, refund: refund, provider_result: provider_result })
        rescue ActiveRecord::RecordInvalid => e
          failure(e.message, :refund_update_failed)
        end

        private

        attr_reader :payment, :refund, :gateway

        def payment_gateway_for(payment)
          gateway || Payments::Application::Gateways.resolve(payment.provider)
        end

        def handle_provider_failure(provider_result)
          provider_data = provider_result.respond_to?(:data) ? provider_result.data.to_h : {}
          failure(provider_result.message, provider_result.code, provider_data.merge(payment_id: payment.id))
        end

        def failure(message, code, data = {})
          Core::Result::Failure.(message: message, code: code, data: data.merge(payment_id: payment.id))
        end
      end
    end
  end
end
