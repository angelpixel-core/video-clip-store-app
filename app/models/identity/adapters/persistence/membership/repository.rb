module Identity
  module Adapters
    module Persistence
      module Membership
        class Repository < Identity::Domain::Repositories::Membership::Contract
          def find_by_user(user)
            Identity::Domain::Aggregates::Membership.where(user_id: user.id)
          end

          def find_by_account(account)
            Identity::Domain::Aggregates::Membership.where(account_id: account.id)
          end

          def find_by_user_and_account(user, account)
            Identity::Domain::Aggregates::Membership.find_by(user_id: user.id, account_id: account.id)
          end

          def save(membership)
            membership.save!
            membership
          end
        end
      end
    end
  end
end
