source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

group :production, :qa do
  # Use PostgreSQL for Render runtime environments, including QA.
  gem "pg", "~> 1.5"
end
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use Vite for frontend assets [https://github.com/ElMassimo/vite_ruby]
gem "vite_rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "aasm", "~> 6.0"
gem "dry-system", "~> 1.2"
gem "data_migrate", "~> 11.3.1"
gem "packwerk", "~> 3.3"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "payment-sdk", path: "vendor/gems/payment-ruby-sdk"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 2.0"
gem "mini_magick", "~> 5.3"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "rspec-rails"
  gem "capybara"
  gem "selenium-webdriver", "~> 4.46"
  gem "cucumber"
  gem "cucumber-rails", require: false
  gem "database_cleaner-active_record"
  gem "factory_bot_rails"
  gem "webmock"
  gem "vcr"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Preview outgoing emails locally in a browser UI.
  gem "letter_opener_web"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end
