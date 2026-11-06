module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Handler
            DEMO_FAILURE_MESSAGE = "Demo transient webhook failure.".freeze

            HANDLED_EVENT_TYPES = {
              "payment.succeeded" => Succeeded,
              "payment.failed" => Failed,
              "payment.refunded" => Refunded
            }.freeze

            def self.call(event:)
              new(event:).call
            end

            def initialize(event:)
              @event = event
            end

            def call
              attempt = nil

              event.with_lock do
                attempt = event.record_processing_attempt!
              end

              maybe_fail_demo_once!(attempt)

              event.with_lock do
                return already_processed_result(attempt:) if event.processed_at.present?

                handler = HANDLED_EVENT_TYPES[event.event_type]
                return fail_event("Unsupported payment webhook event type.", :unknown_event_type, attempt:) unless handler

                payment = locate_payment
                return fail_event("Unable to locate payment for webhook event.", :payment_not_found, attempt:) unless payment

                event.synchronize_payment_context!(payment)

                handler.call(event: event, payment: payment, attempt: attempt)
              end
            rescue Payments::Domain::Errors::DemoTransientFailure => e
              record_demo_failure!(e.message, attempt: attempt)
              raise
            end

            private

            attr_reader :event

            def already_processed_result(attempt:)
              event.mark_processed!(attempt: attempt)
              Core::Result::Success.(data: { event: event, payment: associated_payment, applied: false, reason: :already_processed })
            end

            def locate_payment
              payment = payment_by_id
              return payment if payment.present?

              payment_by_provider_reference
            end

            def payment_by_id
              payment_id = event_payload["data"].to_h["payment_id"].presence
              return if payment_id.blank?

              Payments::Domain::Repositories::PaymentRepository.find_by_id(payment_id)
            end

            def payment_by_provider_reference
              reference = event_payload["data"].to_h["provider_reference"].presence || event_payload["provider_reference"].presence
              return if reference.blank?

              Payments::Domain::Repositories::PaymentRepository.find_by_provider_reference(reference)
            end

            def associated_payment
              locate_payment
            end

            def fail_event(message, code, attempt: nil)
              event.mark_failed!(message, attempt: attempt) if event.persisted?
              Core::Result::Failure.(message: message, code: code, data: { event: event })
            end

            def maybe_fail_demo_once!(attempt)
              return raise_demo_transient_failure! if demo_fail_always?
              return unless demo_fail_once?
              return unless attempt.present? && attempt.attempt_number == 1

              raise_demo_transient_failure!
            end

            def demo_fail_always?
              ActiveModel::Type::Boolean.new.cast(event_payload["data"].to_h["demo_fail_always"])
            end

            def raise_demo_transient_failure!
              raise Payments::Domain::Errors::DemoTransientFailure, DEMO_FAILURE_MESSAGE
            end

            def demo_fail_once?
              ActiveModel::Type::Boolean.new.cast(event_payload["data"].to_h["demo_fail_once"])
            end

            def record_demo_failure!(message, attempt: nil)
              event.mark_failed!(message, attempt: attempt)
            end

            def event_payload
              @event_payload ||= event.payload.to_h
            end
          end
        end
      end
    end
  end
end
