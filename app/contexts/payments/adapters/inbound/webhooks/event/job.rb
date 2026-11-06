module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Job < ApplicationJob
            MAX_RETRY_ATTEMPTS = Payments::Domain::Policies::RetryPolicy::MAX_ATTEMPTS

            retry_on Payments::Domain::Errors::DemoTransientFailure, wait: 0.seconds, attempts: MAX_RETRY_ATTEMPTS do |job, error|
              job.class.handle_retry_exhaustion(payment_webhook_event_id: job.arguments.first, error: error)
            end

            retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: MAX_RETRY_ATTEMPTS do |job, error|
              job.class.handle_retry_exhaustion(payment_webhook_event_id: job.arguments.first, error: error)
            end

            def perform(payment_webhook_event_id)
              event = Payments::Adapters::Persistence::Webhook::Event::Repository.find_by_id(payment_webhook_event_id)
              return unless event.present?

              Payments::Adapters::Inbound::Webhooks::Event::Handler.(event: event)
            end

            def self.handle_retry_exhaustion(payment_webhook_event_id:, error:)
              Payments::Adapters::Inbound::Webhooks::Event::FinalFailureHandler.call(
                payment_webhook_event_id: payment_webhook_event_id,
                error: error
              )
            end
          end
        end
      end
    end
  end
end
