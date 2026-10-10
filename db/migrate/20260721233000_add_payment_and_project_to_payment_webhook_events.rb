class AddPaymentAndProjectToPaymentWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :payment_webhook_events, :payment, null: true, foreign_key: true
    add_reference :payment_webhook_events, :project, null: true, foreign_key: true

    add_index :payment_webhook_events, %i[payment_id provider_event_id], unique: true, name: "index_payment_webhook_events_on_payment_and_provider_event_id"
    add_index :payment_webhook_events, %i[project_id status], name: "index_payment_webhook_events_on_project_id_and_status"
  end
end
