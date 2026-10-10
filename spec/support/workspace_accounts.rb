module WorkspaceAccounts
  def workspace_account(role, email: nil, name: nil)
    email ||= default_workspace_email(role)
    name ||= default_workspace_name(role)

    account = find_or_create_workspace_account(email:, role:, name:)
    account.update_columns(name: name) if account.name != name

    user = find_or_create_workspace_user(email:, name:)
    user.update_columns(name: name, access_state: "active", notification_settings: {}) if user.name != name || user.access_state != "active" || user.notification_settings.blank?

    Identity::Domain::Aggregates::Membership.find_or_create_by!(user: user, account: account) do |membership|
      membership.role = role
    end

    account
  end

  def find_workspace_account(role, email: nil)
    email ||= default_workspace_email(role)

    Identity::Domain::Aggregates::Account.find_by!(email: normalized_workspace_email(email), role: normalized_workspace_role(role))
  end

  def find_or_create_workspace_account(email:, role:, name:)
    normalized_email = normalized_workspace_email(email)
    normalized_role = normalized_workspace_role(role)

    Identity::Domain::Aggregates::Account.find_by(email: normalized_email, role: normalized_role) ||
      Identity::Domain::Aggregates::Account.create!(name: name, email: normalized_email, role: normalized_role)
  rescue ActiveRecord::RecordNotUnique
    Identity::Domain::Aggregates::Account.find_by!(email: normalized_workspace_email(email), role: normalized_workspace_role(role))
  end

  def find_or_create_workspace_user(email:, name:)
    normalized_email = normalized_workspace_email(email)

    Identity::Domain::Aggregates::User.find_by(email: normalized_email) ||
      Identity::Domain::Aggregates::User.create!(name: name, email: normalized_email, access_state: :active, notification_settings: {})
  rescue ActiveRecord::RecordNotUnique
    Identity::Domain::Aggregates::User.find_by!(email: normalized_workspace_email(email))
  end
end

RSpec.configure do |config|
  config.include WorkspaceAccounts

  config.around(:each, type: :request) do |example|
    original_client = ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"]
    original_pm = ENV["DEFAULT_PM_WORKSPACE_EMAIL"]

    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com" if original_client.blank?
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com" if original_pm.blank?

    example.run

    restore_workspace_env("DEFAULT_CLIENT_WORKSPACE_EMAIL", original_client)
    restore_workspace_env("DEFAULT_PM_WORKSPACE_EMAIL", original_pm)
  end

  config.around(:each, type: :system) do |example|
    original_client = ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"]
    original_pm = ENV["DEFAULT_PM_WORKSPACE_EMAIL"]

    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com" if original_client.blank?
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com" if original_pm.blank?

    example.run

    restore_workspace_env("DEFAULT_CLIENT_WORKSPACE_EMAIL", original_client)
    restore_workspace_env("DEFAULT_PM_WORKSPACE_EMAIL", original_pm)
  end
end

def restore_workspace_env(key, value)
  if value.nil?
    ENV.delete(key)
  else
    ENV[key] = value
  end
end

def normalized_workspace_email(email)
  email.to_s.strip.downcase
end

def normalized_workspace_role(role)
  role.to_s.strip.downcase
end

def default_workspace_email(role)
  normalized_workspace_role(role) == "pm" ? "pm@example.com" : "client@example.com"
end

def default_workspace_name(role)
  normalized_workspace_role(role) == "pm" ? "PM" : "Client"
end
