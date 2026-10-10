module Identity
  module Application
    module Queries
      class ResolveWorkspaceAccount
        def initialize(
          email:,
          role:,
          user_repository: Identity::Domain::Repositories::UserRepository,
          account_repository: Identity::Adapters::Persistence::Account::Repository.new
        )
          @email = email
          @role = role
          @user_repository = user_repository
          @account_repository = account_repository
        end

        def self.call(
          email:,
          role:,
          user_repository: Identity::Domain::Repositories::UserRepository,
          account_repository: Identity::Adapters::Persistence::Account::Repository.new
        )
          new(email:, role:, user_repository:, account_repository:).call
        end

        def call
          Core::Result::Success.(
            data: {
              account: resolve_account(email, role)
            }
          )
        end

        private

        attr_reader :email, :role, :user_repository, :account_repository

        def resolve_account(email, role)
          user = user_repository.find_by_email(email)
          return unless user.present?

          account = account_repository.find_by_user_and_role(user, role)
          return account.first if account.respond_to?(:first)

          account
        end
      end
    end
  end
end
