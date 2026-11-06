module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Handler
            class Failed < Base
              def call
                return finish_noop(:stale_payment_state) if terminal_payment_status?

                from_status = payment.status

                payment.update!(
                  status: :failed,
                  failed_at: Time.current,
                  confirmed_at: nil,
                  provider_reference: payment.provider_reference.presence || event_payload_provider_reference
                )

                update_payment_attempt!(status: :failed, error_message: "Payment failed via webhook.")
                record_notification_intent!(from_status: from_status, to_status: :failed)
                event.mark_processed!(attempt: attempt)

                Core::Result::Success.(data: { event: event, payment: payment, applied: true })
              rescue ActiveRecord::RecordInvalid => e
                Core::Result::Failure.(message: e.message, code: :payment_update_failed, data: { event: event })
              end

              private

              def event_payload_provider_reference
                payload = event.payload.to_h
                payload["data"].to_h["provider_reference"].presence || payload["provider_reference"].presence
              end
            end
          end
        end
      end
    end
  end
end
