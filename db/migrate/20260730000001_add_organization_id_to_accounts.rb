class AddOrganizationIdToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_reference :accounts, :organization, null: true, foreign_key: true
  end
end
