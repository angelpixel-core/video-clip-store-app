# Data Bootstrap Migrations

This directory contains minimum required bootstrap data migrations.

## Conventions

- Use timestamped Ruby files.
- Keep migrations idempotent.
- Use environment variables for environment-specific bootstrap values.
- Keep demo/sample data in `db/seeds.rb`.

## Execution

- `bundle exec rails data:migrate`
- `bundle exec rails db:migrate:with_data`
