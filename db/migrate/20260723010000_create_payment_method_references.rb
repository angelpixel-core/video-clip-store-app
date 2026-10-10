class CreatePaymentMethodReferences < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_method_references do |t|
      t.references :payment, null: false, foreign_key: true, index: { unique: true }
      t.string :provider, null: false, default: "fake"
      t.string :method_type, null: false
      t.string :reference, null: false
      t.json :metadata

      t.timestamps
    end

    add_index :payment_method_references, :reference, unique: true
    add_index :payment_method_references, %i[provider method_type]
  end
end
