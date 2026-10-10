module Billing
  module Application
    module Handlers
      class DispatchInvoiceJob < ApplicationJob
        retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: 5

        def perform(payment_invoice_delivery_intent_id)
          intent = Payments::Domain::Entities::PaymentInvoiceDeliveryIntent.find_by(id: payment_invoice_delivery_intent_id)
          return unless intent.present?
          return if intent.sent?

          intent.payment.with_lock do
            return if intent.payment.invoice_emailed_at.present?

            Billing::Adapters::Outbound::Mailers::InvoiceMailer.invoice_ready(intent).deliver_now
            intent.payment.update!(invoice_emailed_at: Time.current)
            intent.mark_sent!
          end
        rescue StandardError => e
          intent.mark_failed!(e.message) if intent.present?
          raise
        end
      end
    end
  end
end
