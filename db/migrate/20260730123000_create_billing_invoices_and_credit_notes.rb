class CreateBillingInvoicesAndCreditNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_invoices do |t|
      t.string :number, null: false
      t.references :payment, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: { to_table: :projects }
      t.string :order_name, null: false
      t.string :recipient_name, null: false
      t.string :recipient_email, null: false
      t.json :lines_json, null: false
      t.json :billing_identity_json
      t.text :content, null: false
      t.string :content_type, null: false, default: "text/html"
      t.string :status, null: false, default: "issued"
      t.integer :tax_amount_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.datetime :issued_at, null: false
      t.datetime :paid_at

      t.timestamps
    end

    add_index :billing_invoices, :number, unique: true

    create_table :billing_credit_notes do |t|
      t.string :number, null: false
      t.references :invoice, null: false, foreign_key: { to_table: :billing_invoices }
      t.integer :amount_cents, null: false, default: 0
      t.string :reason, null: false
      t.string :status, null: false, default: "issued"
      t.datetime :issued_at, null: false

      t.timestamps
    end

    add_index :billing_credit_notes, :number, unique: true
  end
end
