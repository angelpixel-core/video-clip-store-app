module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class FinalFailureHandler
            def self.call(payment_webhook_event_id:, error:)
              new(payment_webhook_event_id:, error:).call
            end

            def initialize(payment_webhook_event_id:, error:)
              @payment_webhook_event_id = payment_webhook_event_id
              @error = error
            end

            def call
              event = Payments::Adapters::Persistence::Webhook::Event::Repository.find_by_id(payment_webhook_event_id)
              return unless event.present?

              event.with_lock do
                payment = event.payment || locate_payment(event)
                return finish_noop(event:, payment:, reason: :payment_not_found) unless payment.present?
                return finish_noop(event:, payment:, reason: :stale_payment_state) if payment.status_object.terminal?

                from_status = payment.status
                failure_message = error.message.presence || event.last_failure_message.presence || "Payment webhook processing failed after retries."
                failure_reason_code = Payments::Domain::Policies::FailureReasonNormalizer.call(error:, event:)
                current_attempt = event.processing_attempts.order(:attempt_number).last

                payment.update!(
                  status: :failed,
                  failed_at: Time.current,
                  confirmed_at: nil,
                  provider_reference: payment.provider_reference.presence || event_payload_provider_reference(event)
                )

                update_payment_attempt!(payment:, event:, error_message: failure_message)
                event.mark_failed!(failure_message, attempt: current_attempt, failure_reason_code: failure_reason_code)

                Payments::Domain::Entities::PaymentNotificationIntent.create!(
                  payment: payment,
                  project: payment.project,
                  event_type: "payment.failed_final",
                  from_status: from_status,
                  to_status: "failed",
                  payload: {
                    payment_id: payment.id,
                    order_id: payment.project_id,
                    provider_event_id: event.provider_event_id,
                    webhook_event_id: event.id,
                    payment_status: "failed",
                    failure_reason_code: failure_reason_code,
                    failure_message: failure_message,
                    failure_class: error.class.name
                  },
                  status: :pending,
                  scheduled_at: Time.current
                )

                Core::Result::Success.(data: { event: event, payment: payment, applied: true })
              end
            rescue ActiveRecord::RecordInvalid => e
              Core::Result::Failure.(message: e.message, code: :payment_update_failed, data: { event: event })
            end

            private

            attr_reader :payment_webhook_event_id, :error

            def locate_payment(event)
              payment_id = event.payload.to_h.fetch("data", {}).to_h["payment_id"].presence
              return if payment_id.blank?

              Payments::Domain::Repositories::PaymentRepository.find_by_id(payment_id)
            end

            def update_payment_attempt!(payment:, event:, error_message:)
              recent_attempt = payment.payment_attempts.order(created_at: :desc).first
              return unless recent_attempt.present?

              recent_attempt.update!(
                status: :failed,
                error_message: error_message,
                response_payload: recent_attempt.response_payload.to_h.merge("webhook_event_id" => event.provider_event_id, "webhook_event_type" => event.event_type)
              )
            end

            def event_payload_provider_reference(event)
              payload = event.payload.to_h
              payload["data"].to_h["provider_reference"].presence || payload["provider_reference"].presence
            end

            def finish_noop(event:, payment:, reason:)
              event.mark_processed!(attempt: event.processing_attempts.order(:attempt_number).last)
              Core::Result::Success.(data: { event: event, payment: payment, applied: false, reason: reason })
            end
          end
        end
      end
    end
  end
end
