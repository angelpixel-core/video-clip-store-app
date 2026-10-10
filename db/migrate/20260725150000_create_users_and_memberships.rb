class CreateUsersAndMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :access_state, null: false, default: "active"
      t.string :preferred_locale
      t.string :timezone
      t.json :notification_settings, null: false
      t.datetime :invited_at
      t.datetime :verified_at
      t.datetime :suspended_at
      t.datetime :deactivated_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :access_state

    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: { to_table: :accounts }
      t.string :role, null: false

      t.timestamps
    end

    add_index :memberships, %i[user_id account_id], unique: true
    add_index :memberships, %i[account_id role]
  end
end
