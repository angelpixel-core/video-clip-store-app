module Identity
  module Domain
    module Repositories
      class UserRepository
        def self.repository
          @repository ||= Identity::Adapters::Persistence::User::Repository.new
        end

        def self.find_by_email(email)
          repository.find_by_email(email)
        end

        def self.find_by_role(role)
          repository.find_by_role(role)
        end

        def self.find_by_email_and_role(email, role)
          repository.find_by_email_and_role(email, role)
        end

        def self.find_by_id(id)
          repository.find_by_id(id)
        end

        def self.save(user)
          repository.save(user)
        end
      end
    end
  end
end
