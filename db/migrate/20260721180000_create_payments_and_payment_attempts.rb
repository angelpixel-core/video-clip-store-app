class CreatePaymentsAndPaymentAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :project, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :provider, null: false, default: "fake"
      t.string :provider_reference
      t.string :idempotency_key, null: false
      t.integer :amount_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.datetime :confirmed_at
      t.datetime :failed_at
      t.datetime :canceled_at

      t.timestamps
    end

    add_index :payments, :idempotency_key, unique: true
    add_index :payments, :provider_reference, unique: true
    add_index :payments, %i[project_id status]

    create_table :payment_attempts do |t|
      t.references :payment, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :provider, null: false, default: "fake"
      t.string :provider_reference
      t.string :idempotency_key, null: false
      t.json :request_payload
      t.json :response_payload
      t.text :error_message

      t.timestamps
    end

    add_index :payment_attempts, :idempotency_key, unique: true
    add_index :payment_attempts, :provider_reference, unique: true
    add_index :payment_attempts, %i[payment_id status]
  end
end
