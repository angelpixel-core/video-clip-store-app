class AllowBlankFieldsOnProjectsForDrafts < ActiveRecord::Migration[8.1]
  def change
    change_column_null :projects, :name, true
    change_column_null :projects, :raw_footage_url, true
  end
end
