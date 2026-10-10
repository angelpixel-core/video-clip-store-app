class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :role, null: false
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :accounts, %i[email role], unique: true
    add_index :accounts, :role
  end
end
