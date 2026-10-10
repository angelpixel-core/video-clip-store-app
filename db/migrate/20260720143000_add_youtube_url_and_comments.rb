class AddYoutubeUrlAndComments < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :youtube_url, :string

    create_table :comments do |t|
      t.references :project, null: false, foreign_key: true
      t.string :author_type, null: false
      t.bigint :author_id, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :comments, %i[author_type author_id]
  end
end
