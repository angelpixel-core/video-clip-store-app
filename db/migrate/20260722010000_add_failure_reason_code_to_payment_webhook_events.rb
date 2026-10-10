class AddFailureReasonCodeToPaymentWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_webhook_events, :failure_reason_code, :string
    add_index :payment_webhook_events, :failure_reason_code
  end
end
