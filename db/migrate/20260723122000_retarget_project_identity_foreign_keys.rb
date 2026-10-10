class RetargetProjectIdentityForeignKeys < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :projects, :clients
    remove_foreign_key :projects, :pms

    add_foreign_key :projects, :accounts, column: :client_id
    add_foreign_key :projects, :accounts, column: :pm_id
  end
end
