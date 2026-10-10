class CreatePaymentWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_webhook_events do |t|
      t.string :provider, null: false
      t.string :provider_event_id, null: false
      t.string :event_type, null: false
      t.string :status, null: false, default: "received"
      t.json :payload, null: false
      t.string :signature
      t.datetime :received_at, null: false
      t.datetime :processed_at
      t.text :error_message

      t.timestamps
    end

    add_index :payment_webhook_events, %i[provider provider_event_id], unique: true, name: "index_payment_webhook_events_on_provider_and_event_id"
    add_index :payment_webhook_events, :provider
    add_index :payment_webhook_events, :status
  end
end
