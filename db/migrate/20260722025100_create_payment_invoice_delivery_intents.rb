class CreatePaymentInvoiceDeliveryIntents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_invoice_delivery_intents do |t|
      t.references :payment, null: false, foreign_key: true, index: { unique: true }
      t.string :status, null: false, default: "pending"
      t.integer :attempts_count, null: false, default: 0
      t.text :last_error
      t.datetime :scheduled_at, null: false
      t.datetime :processed_at

      t.timestamps
    end
  end
end
