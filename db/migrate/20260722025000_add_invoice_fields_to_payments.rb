class AddInvoiceFieldsToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :invoice_number, :string
    add_column :payments, :invoice_generated_at, :datetime
    add_column :payments, :invoice_emailed_at, :datetime

    add_index :payments, :invoice_number, unique: true
  end
end
