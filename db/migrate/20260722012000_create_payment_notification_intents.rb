class CreatePaymentNotificationIntents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_notification_intents do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :from_status, null: false
      t.string :to_status, null: false
      t.json :payload, null: false
      t.string :status, null: false, default: "pending"
      t.integer :attempts_count, null: false, default: 0
      t.text :last_error
      t.datetime :scheduled_at
      t.datetime :processed_at

      t.timestamps
    end

    add_index :payment_notification_intents, %i[payment_id event_type], unique: true, name: "index_payment_notification_intents_on_payment_and_event_type"
    add_index :payment_notification_intents, %i[status scheduled_at], name: "index_payment_notification_intents_on_status_and_scheduled_at"
  end
end
