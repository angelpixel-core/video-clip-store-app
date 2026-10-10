class MigrateIdentityToAccounts < ActiveRecord::Migration[8.1]
  def up
    add_reference :projects, :client_account, foreign_key: { to_table: :accounts }
    add_reference :projects, :pm_account, foreign_key: { to_table: :accounts }
    add_reference :notifications, :account, foreign_key: { to_table: :accounts }
    add_reference :comments, :author_account, foreign_key: { to_table: :accounts }

    execute <<~SQL.squish
      INSERT INTO accounts (role, name, email, created_at, updated_at)
      SELECT 'client', clients.name, clients.email, clients.created_at, clients.updated_at
      FROM clients
      ON DUPLICATE KEY UPDATE name = VALUES(name), updated_at = VALUES(updated_at)
    SQL

    execute <<~SQL.squish
      INSERT INTO accounts (role, name, email, created_at, updated_at)
      SELECT 'pm', pms.name, pms.email, pms.created_at, pms.updated_at
      FROM pms
      ON DUPLICATE KEY UPDATE name = VALUES(name), updated_at = VALUES(updated_at)
    SQL

    execute <<~SQL.squish
      UPDATE projects
      INNER JOIN clients ON clients.id = projects.client_id
      INNER JOIN accounts client_accounts ON client_accounts.email = clients.email AND client_accounts.role = 'client'
      SET projects.client_account_id = client_accounts.id
    SQL

    execute <<~SQL.squish
      UPDATE projects
      INNER JOIN pms ON pms.id = projects.pm_id
      INNER JOIN accounts pm_accounts ON pm_accounts.email = pms.email AND pm_accounts.role = 'pm'
      SET projects.pm_account_id = pm_accounts.id
    SQL

    execute <<~SQL.squish
      UPDATE notifications
      INNER JOIN clients ON clients.id = notifications.client_id
      INNER JOIN accounts client_accounts ON client_accounts.email = clients.email AND client_accounts.role = 'client'
      SET notifications.account_id = client_accounts.id
      WHERE notifications.client_id IS NOT NULL
    SQL

    execute <<~SQL.squish
      UPDATE notifications
      INNER JOIN pms ON pms.id = notifications.pm_id
      INNER JOIN accounts pm_accounts ON pm_accounts.email = pms.email AND pm_accounts.role = 'pm'
      SET notifications.account_id = pm_accounts.id
      WHERE notifications.pm_id IS NOT NULL
    SQL

    execute <<~SQL.squish
      UPDATE comments
      INNER JOIN clients ON comments.author_type = 'Client' AND clients.id = comments.author_id
      INNER JOIN accounts client_accounts ON client_accounts.email = clients.email AND client_accounts.role = 'client'
      SET comments.author_account_id = client_accounts.id
    SQL

    execute <<~SQL.squish
      UPDATE comments
      INNER JOIN pms ON comments.author_type = 'PM' AND pms.id = comments.author_id
      INNER JOIN accounts pm_accounts ON pm_accounts.email = pms.email AND pm_accounts.role = 'pm'
      SET comments.author_account_id = pm_accounts.id
    SQL
  end

  def down
    remove_reference :comments, :author_account, foreign_key: { to_table: :accounts }
    remove_reference :notifications, :account, foreign_key: { to_table: :accounts }
    remove_reference :projects, :pm_account, foreign_key: { to_table: :accounts }
    remove_reference :projects, :client_account, foreign_key: { to_table: :accounts }
  end
end
