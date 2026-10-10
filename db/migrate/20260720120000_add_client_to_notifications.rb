class AddClientToNotifications < ActiveRecord::Migration[8.1]
  def change
    change_column_null :notifications, :pm_id, true

    add_reference :notifications, :client, null: true, foreign_key: true

    add_check_constraint :notifications,
                         "(pm_id IS NOT NULL AND client_id IS NULL) OR (pm_id IS NULL AND client_id IS NOT NULL)",
                         name: "notifications_single_recipient"
  end
end
