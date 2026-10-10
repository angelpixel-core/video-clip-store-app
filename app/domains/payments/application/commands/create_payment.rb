module Payments
  module Application
    module Commands
      class CreatePayment
        def self.call(order: nil, project: nil, provider: "fake", payment_method_type: "card", gateway: nil)
          new(order: order || project, provider:, payment_method_type:, gateway:).call
        end

        def initialize(order:, provider: "fake", payment_method_type: "card", gateway: nil)
          @order = order
          @provider = provider.to_s.strip.presence || "fake"
          @payment_method_type = payment_method_type.to_s.strip.presence || "card"
          @gateway = gateway
        end

        def call
          order.with_lock do
            return Core::Result::Failure.(message: "Payment request pending review.", code: :refund_request_pending, data: { order_id: order.id }) if order.respond_to?(:payment_flow_blocked?) && order.payment_flow_blocked?

            payment = Payments::Domain::Repositories::PaymentRepository.find_active_by_project(order)
            return Core::Result::Success.(data: { payment: payment, attempt: payment.payment_attempts.order(created_at: :desc).first }) if payment.present?

            create_payment_flow!
          end
        end

        private

        attr_reader :order

        def create_payment_flow!
          payment = order.payments.create!(
            status: :pending,
            provider: provider_name,
            idempotency_key: SecureRandom.uuid,
            amount_cents: order.total_budget_cents,
            currency: "USD"
          )

          payment.create_payment_method_reference!(
            provider: payment.provider,
            method_type: payment_method_type,
            reference: "#{payment.provider}-#{payment.idempotency_key}"
          )

          attempt = payment.payment_attempts.create!(
            status: :pending,
            provider: payment.provider,
            idempotency_key: payment.idempotency_key,
            request_payload: payment_request_payload(payment)
          )

          provider_result = payment_gateway_for(payment).call(payment: payment)

          return handle_provider_failure(payment:, attempt:, provider_result:) if provider_result.failure?

          payment.update!(
            status: :processing,
            provider_reference: provider_result.data.fetch(:provider_reference)
          )

          attempt.update!(
            status: :submitted,
            provider_reference: provider_result.data.fetch(:provider_reference),
            response_payload: provider_result.data.fetch(:response_payload)
          )

          Core::Result::Success.(data: { payment: payment, attempt: attempt, provider_result: provider_result })
        end

        def handle_provider_failure(payment:, attempt:, provider_result:)
          payment.update!(
            status: :failed,
            failed_at: Time.current
          )

          attempt.update!(
            status: :failed,
            error_message: provider_result.message,
            response_payload: provider_result.data
          )

          Core::Result::Failure.(
            message: provider_result.message,
            code: provider_result.code,
            data: provider_result.data.merge(payment_id: payment.id)
          )
        end

        def payment_request_payload(payment)
          {
            order_id: payment.project_id,
            amount_cents: payment.amount_cents,
            currency: payment.currency,
            status: payment.status
          }
        end

        def provider_name
          provider
        end

        def payment_gateway_for(payment)
          gateway || Payments::Application::Gateways.resolve(payment.provider)
        end

        attr_reader :provider, :payment_method_type, :gateway
      end
    end
  end
end
