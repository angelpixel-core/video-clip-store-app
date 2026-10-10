module Identity
  module Adapters
    module Persistence
      module User
        class Repository < Identity::Domain::Repositories::User::Contract
          def find_by_email(email)
            Identity::Domain::Aggregates::User.find_by(email: normalize_email(email))
          end

          def find_by_email_and_role(email, role)
            Identity::Domain::Aggregates::User.joins(:memberships).find_by(
              email: normalize_email(email),
              memberships: { role: normalize_role(role) }
            )
          end

          def find_by_role(role)
            Identity::Domain::Aggregates::User.joins(:memberships).where(memberships: { role: normalize_role(role) }).distinct
          end

          def find_by_id(id)
            Identity::Domain::Aggregates::User.find_by(id: id)
          end

          def save(user)
            user.save!
            user
          end

          private

          def normalize_email(email)
            email.to_s.strip.downcase
          end

          def normalize_role(role)
            role.to_s.strip.downcase
          end
        end
      end
    end
  end
end
