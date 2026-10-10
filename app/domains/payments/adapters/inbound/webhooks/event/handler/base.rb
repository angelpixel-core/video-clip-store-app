module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Handler
            class Base
              def self.call(event:, payment:, attempt:)
                new(event:, payment:, attempt:).call
              end

              def initialize(event:, payment:, attempt:)
                @event = event
                @payment = payment
                @attempt = attempt
              end

              private

              attr_reader :event, :payment, :attempt

              def update_payment_attempt!(status:, error_message: nil)
                recent_attempt = payment.payment_attempts.order(created_at: :desc).first
                return unless recent_attempt.present?

                recent_attempt.update!(
                  status: status,
                  error_message: error_message.presence || recent_attempt.error_message,
                  response_payload: recent_attempt.response_payload.to_h.merge("webhook_event_id" => event.provider_event_id, "webhook_event_type" => event.event_type)
                )
              end

              def record_notification_intent!(from_status:, to_status:, event_type: nil, payload: {})
                Payments::Domain::Entities::PaymentNotificationIntent.create!(
                  payment: payment,
                  project: payment.project,
                  event_type: event_type.presence || "payment.#{to_status}",
                  from_status: from_status,
                  to_status: to_status,
                  payload: {
                    payment_id: payment.id,
                    order_id: payment.project_id,
                    provider_event_id: event.provider_event_id,
                    webhook_event_id: event.id,
                    payment_status: to_status
                  }.merge(payload),
                  status: :pending,
                  scheduled_at: Time.current
                )
              end

              def finish_noop(reason)
                event.mark_processed!(attempt: attempt)
                Core::Result::Success.(data: { event: event, payment: payment, applied: false, reason: reason })
              end

              def terminal_payment_status?
                Payments::Domain::Aggregates::Payment::TERMINAL_STATUSES.include?(payment.status)
              end
            end
          end
        end
      end
    end
  end
end
