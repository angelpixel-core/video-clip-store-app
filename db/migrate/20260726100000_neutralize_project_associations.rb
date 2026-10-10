class NeutralizeProjectAssociations < ActiveRecord::Migration[8.1]
  class ProjectRecord < ActiveRecord::Base
    self.table_name = "projects"
  end

  def up
    add_reference :projects, :owner_account, null: true, foreign_key: { to_table: :accounts }
    add_reference :projects, :participant_account, null: true, foreign_key: { to_table: :accounts }

    execute <<~SQL.squish
      UPDATE projects
      SET owner_account_id = COALESCE(client_account_id, client_id),
          participant_account_id = COALESCE(pm_account_id, pm_id)
    SQL

    change_column_null :projects, :owner_account_id, false
    change_column_null :projects, :participant_account_id, false

    remove_foreign_key :projects, column: :client_account_id
    remove_foreign_key :projects, column: :client_id
    remove_foreign_key :projects, column: :pm_account_id
    remove_foreign_key :projects, column: :pm_id

    remove_column :projects, :client_account_id
    remove_column :projects, :client_id
    remove_column :projects, :pm_account_id
    remove_column :projects, :pm_id
  end

  def down
    add_reference :projects, :client_account, null: true, foreign_key: { to_table: :accounts }
    add_reference :projects, :client, null: true, foreign_key: { to_table: :accounts }
    add_reference :projects, :pm_account, null: true, foreign_key: { to_table: :accounts }
    add_reference :projects, :pm, null: true, foreign_key: { to_table: :accounts }

    execute <<~SQL.squish
      UPDATE projects
      SET client_account_id = owner_account_id,
          client_id = owner_account_id,
          pm_account_id = participant_account_id,
          pm_id = participant_account_id
    SQL

    remove_foreign_key :projects, column: :owner_account_id
    remove_foreign_key :projects, column: :participant_account_id

    remove_column :projects, :owner_account_id
    remove_column :projects, :participant_account_id
  end
end
