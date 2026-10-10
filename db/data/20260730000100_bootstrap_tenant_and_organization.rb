# frozen_string_literal: true

class BootstrapTenantAndOrganization < ActiveRecord::Migration[8.1]
  def up
    tenant = bootstrap_tenant!
    organization = bootstrap_organization!(tenant: tenant)

    Identity::Domain::Aggregates::Account.where(organization_id: nil).update_all(
      organization_id: organization.id,
      updated_at: Time.current
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def bootstrap_tenant!
    Identity::Domain::Aggregates::Tenant.find_or_create_by!(slug: env_value("DEFAULT_TENANT_SLUG", "wanderlust")) do |record|
      record.name = env_value("DEFAULT_TENANT_NAME", "Wanderlust")
    end
  end

  def bootstrap_organization!(tenant:)
    Identity::Domain::Aggregates::Organization.find_or_create_by!(tenant: tenant, slug: env_value("DEFAULT_ORGANIZATION_SLUG", "wanderlust-videos")) do |record|
      record.name = env_value("DEFAULT_ORGANIZATION_NAME", "Wanderlust Videos")
    end
  end

  def env_value(key, default)
    ENV.fetch(key, default)
  end
end
