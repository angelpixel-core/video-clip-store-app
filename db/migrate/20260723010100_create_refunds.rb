class CreateRefunds < ActiveRecord::Migration[8.1]
  def change
    create_table :refunds do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :payment_method_reference, null: false, foreign_key: true
      t.string :provider, null: false, default: "fake"
      t.string :provider_reference
      t.string :status, null: false, default: "pending"
      t.integer :amount_cents, null: false, default: 0
      t.text :reason
      t.datetime :processed_at

      t.timestamps
    end

    add_index :refunds, :provider_reference, unique: true
    add_index :refunds, %i[payment_id status]
    add_index :refunds, %i[payment_method_reference_id status]
  end
end
