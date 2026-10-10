module Identity
  module Adapters
    module Persistence
      module Organization
        class OrganizationRecord < ApplicationRecord
          self.table_name = "organizations"

          belongs_to :tenant, class_name: "Identity::Domain::Aggregates::Tenant"
          has_many :accounts, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :organization_id, dependent: :restrict_with_error

          before_validation :normalize_slug

          validates :name, presence: true
          validates :slug, presence: true, uniqueness: { scope: :tenant_id }

          private

          def normalize_slug
            self.slug = slug.to_s.strip.downcase.presence || name.to_s.parameterize
          end
        end
      end
    end
  end
end
