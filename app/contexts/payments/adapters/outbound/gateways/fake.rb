module Payments
  module Adapters
    module Outbound
      module Gateways
        class Fake < Payments::Application::Ports::Gateway
          def self.call(payment:)
            return Core::Result::Failure.(
              message: "Payment amount must be greater than zero.",
              code: :invalid_amount,
              data: { payment_id: payment.id, amount_cents: payment.amount_cents }
            ) if payment.amount_cents <= 0

            provider_reference = "fake-#{payment.idempotency_key}"

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

          def self.refund(payment:, refund:)
            provider_reference = "refund-#{refund.provider_reference.presence || payment.idempotency_key}"

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
