module Identity
  module Adapters
    module Persistence
      module User
        class UserRecord < ApplicationRecord
          self.table_name = "users"

          has_many :memberships, class_name: "Identity::Domain::Aggregates::Membership", foreign_key: :user_id, dependent: :destroy
          has_many :accounts, through: :memberships

          before_validation :normalize_email
          before_validation :normalize_access_state
          before_validation :normalize_notification_settings

          validates :name, presence: true
          validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
          validates :access_state, presence: true, inclusion: { in: %w[active invited suspended deactivated] }

          def active?
            access_state == "active"
          end

          def invited?
            access_state == "invited"
          end

          def suspended?
            access_state == "suspended"
          end

          def deactivated?
            access_state == "deactivated"
          end

          def membership_for(account)
            memberships.find_by(account_id: account.id)
          end

          def role_for(account)
            membership_for(account)&.role_object
          end

          def member_of?(account)
            membership_for(account).present?
          end

          def roles
            memberships.map(&:role_object).uniq
          end

          private

          def normalize_email
            self.email = email.to_s.strip.downcase
          end

          def normalize_access_state
            self.access_state = access_state.to_s.strip.downcase.presence || "active"
          end

          def normalize_notification_settings
            self.notification_settings = notification_settings.presence || {}
          end
        end
      end
    end
  end
end
