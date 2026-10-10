class CreateOfferCatalog < ActiveRecord::Migration[8.1]
  def change
    create_table :offers, if_not_exists: true do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :offers, :key, unique: true
    add_index :offers, :name, unique: true

    create_table :offer_item_types, if_not_exists: true do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.string :input_kind, null: false, default: "selection"
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :offer_item_types, :key, unique: true
    add_index :offer_item_types, :name, unique: true

    create_table :offer_item_type_assignments, if_not_exists: true do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :offer_item_type, null: false, foreign_key: true
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0
      t.integer :min_selections
      t.integer :max_selections

      t.timestamps
    end

    add_index :offer_item_type_assignments, %i[offer_id offer_item_type_id], unique: true, name: "index_offer_item_type_assignments_on_offer_and_item_type"
    add_index :offer_item_type_assignments, %i[offer_id position]

    create_table :offer_variants, if_not_exists: true do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :offer_item_type, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false, default: 0
      t.string :output_format
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :offer_variants, %i[offer_id key], unique: true
    add_index :offer_variants, %i[offer_id offer_item_type_id position], name: "index_offer_variants_on_offer_item_type_and_position"
    add_index :offer_variants, :name
  end
end
