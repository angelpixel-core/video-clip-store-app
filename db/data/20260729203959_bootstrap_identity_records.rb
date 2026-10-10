# frozen_string_literal: true

class BootstrapIdentityRecords < ActiveRecord::Migration[8.1]
  def up
    bootstrap_workspace!(
      role: :client,
      email: workspace_email("DEFAULT_CLIENT_WORKSPACE_EMAIL", "client@example.com"),
      name: "Default Client"
    )

    bootstrap_workspace!(
      role: :pm,
      email: workspace_email("DEFAULT_PM_WORKSPACE_EMAIL", "pm@example.com"),
      name: "Default PM"
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def bootstrap_workspace!(role:, email:, name:)
    account = Identity::Domain::Aggregates::Account.find_or_create_by!(email: email, role: role) do |record|
      record.name = name
      record.role = role
    end

    user = Identity::Domain::Aggregates::User.find_or_create_by!(email: email) do |record|
      record.name = name
      record.access_state = :active
      record.notification_settings = {}
    end

    Identity::Domain::Aggregates::Membership.find_or_create_by!(user: user, account: account) do |membership|
      membership.role = role
    end
  end

  def workspace_email(key, default)
    ENV.fetch(key, default)
  end
end
