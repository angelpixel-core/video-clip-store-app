module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Handler
            class Refunded < Base
              def call
                return finish_noop(:stale_payment_state) if payment.status == "refunded"

                from_status = payment.status
                refund = locate_refund

                payment.update!(
                  status: :refunded,
                  failed_at: nil,
                  confirmed_at: payment.confirmed_at.presence || Time.current,
                  provider_reference: payment.provider_reference.presence || event_payload_provider_reference
                )

                refund&.update!(
                  status: :refunded,
                  provider_reference: refund.provider_reference.presence || event_payload_provider_reference,
                  processed_at: Time.current
                )

                update_payment_attempt!(status: :succeeded)
                record_notification_intent!(from_status: from_status, to_status: :refunded, event_type: "payment.refunded")
                event.mark_processed!(attempt: attempt)

                Core::Result::Success.(data: { event: event, payment: payment, applied: true, refund: refund })
              rescue ActiveRecord::RecordInvalid => e
                Core::Result::Failure.(message: e.message, code: :payment_update_failed, data: { event: event })
              end

              private

              def locate_refund
                reference = event.payload.to_h["data"].to_h["refund_id"].presence
                return payment.refunds.find_by(id: reference) if reference.present?

                provider_reference = event_payload_provider_reference
                return payment.refunds.find_by(provider_reference: provider_reference) if provider_reference.present?

                payment.refunds.refund_processing.order(created_at: :desc).first || payment.refunds.refund_pending.order(created_at: :desc).first
              end

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
