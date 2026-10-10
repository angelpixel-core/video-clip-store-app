module Payments
  module Application
    module Handlers
      class DispatchPaymentNotificationJob < ApplicationJob
        retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: 5

        def perform(payment_notification_intent_id)
          intent = Payments::Domain::Entities::PaymentNotificationIntent.find_by(id: payment_notification_intent_id)
          return unless intent.present?
          return if intent.sent?

          Rails.logger.info("Payment notification #{intent.event_type} for payment #{intent.payment_id} (#{intent.from_status} -> #{intent.to_status})")
          Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer.payment_status_changed(intent, recipient_role: :client).deliver_now
          Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer.payment_status_changed(intent, recipient_role: :pm).deliver_now
          intent.mark_sent!
        rescue StandardError => e
          intent.mark_failed!(e.message) if intent.present?
          raise
        end
      end
    end
  end
end
