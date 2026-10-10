module Identity
  module Adapters
    module Persistence
      module Tenant
        class TenantRecord < ApplicationRecord
          self.table_name = "tenants"

          has_many :organizations, class_name: "Identity::Domain::Aggregates::Organization", foreign_key: :tenant_id, dependent: :destroy

          before_validation :normalize_slug

          validates :name, presence: true
          validates :slug, presence: true, uniqueness: true

          private

          def normalize_slug
            self.slug = slug.to_s.strip.downcase.presence || name.to_s.parameterize
          end
        end
      end
    end
  end
end
