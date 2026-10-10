class CreateTenantsAndOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :tenants, :slug, unique: true

    create_table :organizations do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :organizations, %i[tenant_id slug], unique: true
  end
end
