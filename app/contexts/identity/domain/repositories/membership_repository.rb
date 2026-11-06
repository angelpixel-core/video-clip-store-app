module Identity
  module Domain
    module Repositories
      class MembershipRepository
        def self.repository
          @repository ||= Identity::Adapters::Persistence::Membership::Repository.new
        end

        def self.find_by_user(user)
          repository.find_by_user(user)
        end

        def self.find_by_account(account)
          repository.find_by_account(account)
        end

        def self.find_by_user_and_account(user, account)
          repository.find_by_user_and_account(user, account)
        end

        def self.save(membership)
          repository.save(membership)
        end
      end
    end
  end
end
