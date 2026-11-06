module Payments
  module Adapters
    module Outbound
      module Gateways
        class Stripe < Payments::Application::Ports::Gateway
          def self.call(payment:)
            fake_result(payment:, provider: "stripe")
          end

          def self.refund(payment:, refund:)
            fake_refund_result(payment:, refund:, provider: "stripe")
          end

          def self.fake_result(payment:, provider:)
            provider_reference = "#{provider}-#{payment.idempotency_key}"

            Core::Result::Success.(
              data: {
                provider_reference: provider_reference,
                provider_status: "accepted",
                request_payload: {
                  payment_id: payment.id,
                  order_id: payment.project_id,
                  amount_cents: payment.amount_cents,
                  currency: payment.currency,
                  idempotency_key: payment.idempotency_key
                },
                response_payload: {
                  provider_reference: provider_reference,
                  status: "accepted"
                }
              }
            )
          end

          def self.fake_refund_result(payment:, refund:, provider:)
            provider_reference = "#{provider}-refund-#{refund.id}"

            Core::Result::Success.(
              data: {
                provider_reference: provider_reference,
                provider_status: "accepted",
                request_payload: {
                  payment_id: payment.id,
                  order_id: payment.project_id,
                  refund_id: refund.id,
                  amount_cents: refund.amount_cents,
                  reason: refund.reason
                },
                response_payload: {
                  provider_reference: provider_reference,
                  status: "accepted"
                }
              }
            )
          end
        end
      end
    end
  end
end
