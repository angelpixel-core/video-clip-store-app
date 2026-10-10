DataMigrate.configure do |config|
  config.data_migrations_path = Rails.root.join("db/data").to_s
end
