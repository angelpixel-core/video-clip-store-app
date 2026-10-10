required_active_storage_env_vars = %w[
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_REGION
  AWS_BUCKET
].freeze

if Rails.env.qa? || Rails.env.production?
  missing = required_active_storage_env_vars.select { |key| ENV[key].to_s.empty? }

  if missing.any?
    raise "Missing required ActiveStorage env vars for #{Rails.env}: #{missing.join(", ")}"
  end
end
