class AddRawFootageMetadataToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :raw_footage_metadata, :json
  end
end
