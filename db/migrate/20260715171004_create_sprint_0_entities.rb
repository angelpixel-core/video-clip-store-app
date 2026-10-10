class CreateSprint0Entities < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :clients, :email, unique: true

    create_table :pms do |t|
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :pms, :email, unique: true

    create_table :video_types do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false, default: 0
      t.string :output_format, null: false

      t.timestamps
    end

    add_index :video_types, :name, unique: true

    create_table :projects do |t|
      t.references :client, null: false, foreign_key: true
      t.references :pm, null: false, foreign_key: { to_table: :pms }
      t.string :name, null: false
      t.string :raw_footage_url, null: false
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :projects, :status

    create_table :video_type_selections do |t|
      t.references :project, null: false, foreign_key: true
      t.references :video_type, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :video_type_selections, %i[project_id video_type_id], unique: true, name: "index_video_type_selections_on_project_and_video_type"

    create_table :notifications do |t|
      t.references :project, null: false, foreign_key: true
      t.references :pm, null: false, foreign_key: { to_table: :pms }
      t.string :kind, null: false
      t.text :body, null: false
      t.datetime :delivered_at
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :kind
  end
end
