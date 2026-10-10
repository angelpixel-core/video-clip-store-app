class RetargetNotificationIdentityForeignKeys < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :notifications, :clients
    remove_foreign_key :notifications, :pms

    add_foreign_key :notifications, :accounts, column: :client_id
    add_foreign_key :notifications, :accounts, column: :pm_id
  end
end
