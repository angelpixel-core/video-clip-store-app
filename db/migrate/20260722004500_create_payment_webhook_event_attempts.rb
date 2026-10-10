class CreatePaymentWebhookEventAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_webhook_event_attempts do |t|
      t.references :payment_webhook_event, null: false, foreign_key: true
      t.integer :attempt_number, null: false
      t.string :status, null: false, default: "started"
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.text :error_message

      t.timestamps
    end

    add_index :payment_webhook_event_attempts, %i[payment_webhook_event_id attempt_number], unique: true, name: "index_payment_webhook_event_attempts_on_event_and_number"
    add_index :payment_webhook_event_attempts, %i[payment_webhook_event_id status], name: "index_payment_webhook_event_attempts_on_event_and_status"
  end
end
