module Identity
  module Application
    module Services
      class WorkspaceResolver
        def initialize(
          query: Identity::Application::Queries::ResolveWorkspaceAccount,
          account_repository: Identity::Adapters::Persistence::Account::Repository.new,
          user_repository: Identity::Domain::Repositories::UserRepository
        )
          @query = query
          @account_repository = account_repository
          @user_repository = user_repository
        end

        def workspace_for(role)
          resolve_workspace(role)
        end

        private

        attr_reader :query, :account_repository, :user_repository

        def resolve_workspace(role)
          @resolved_workspaces ||= {}
          @resolved_workspaces[role.to_sym] ||= query.call(
            email: required_email_for(role),
            role: role.to_sym,
            user_repository: user_repository,
            account_repository: account_repository
          ).data.fetch(:account)
        end

        def required_email_for(role)
          key = role.to_sym == :pm ? "DEFAULT_PM_WORKSPACE_EMAIL" : "DEFAULT_CLIENT_WORKSPACE_EMAIL"
          value = ENV[key].to_s.strip
          return value if value.present?

          raise KeyError, "Missing required environment variable: #{key}"
        end
      end
    end
  end
end
