class AddProcessingAuditToPaymentWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_webhook_events, :processing_attempts_count, :integer, null: false, default: 0
    add_column :payment_webhook_events, :last_attempted_at, :datetime
    add_column :payment_webhook_events, :last_failure_at, :datetime
    add_column :payment_webhook_events, :last_failure_message, :text
  end
end
