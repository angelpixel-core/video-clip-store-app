module Identity
  module Domain
    module Repositories
      class AccountRepository
        def self.repository
          @repository ||= Identity::Adapters::Persistence::Account::Repository.new
        end

        def self.find_by_email(email)
          repository.find_by_email(email)
        end

        def self.find_by_email_and_role(email, role)
          repository.find_by_email_and_role(email, role)
        end

        def self.find_by_role(role)
          repository.find_by_role(role)
        end

        def self.find_by_user(user)
          repository.find_by_user(user)
        end

        def self.find_by_user_and_role(user, role)
          repository.find_by_user_and_role(user, role)
        end
      end
    end
  end
end
