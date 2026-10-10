module Identity
  module Adapters
    module Persistence
      module Membership
        class MembershipRecord < ApplicationRecord
          self.table_name = "memberships"

          belongs_to :user, class_name: "Identity::Domain::Aggregates::User"
          belongs_to :account, class_name: "Identity::Domain::Aggregates::Account"

          before_validation :normalize_role

          validates :role, presence: true, inclusion: { in: Identity::Domain::ValueObjects::Role::ALLOWED_VALUES }
          validates :user_id, uniqueness: { scope: :account_id }

          def role_object
            Identity::Domain::ValueObjects::Role.new(role)
          end

          def client?
            role_object.client?
          end

          def pm?
            role_object.pm?
          end

          def capabilities
            case role
            when "client"
              %i[read_project submit_project view_notifications]
            when "pm"
              %i[read_project accept_project complete_project view_notifications]
            else
              []
            end
          end

          private

          def normalize_role
            self.role = role.to_s.strip.downcase
          end
        end
      end
    end
  end
end
