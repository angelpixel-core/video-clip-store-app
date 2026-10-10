require "rails_helper"

require Rails.root.join("app/domains/identity/application/queries/resolve_workspace_account")

RSpec.describe Identity::Application::Queries::ResolveWorkspaceAccount do
  it "resolves a workspace through user memberships" do
    workspace = build_client_account(email: "client@example.com", name: "Client")

    user_repository = class_double(Identity::Domain::Repositories::UserRepository).as_stubbed_const
    account_repository = instance_double(Identity::Adapters::Persistence::Account::Repository)

    user = Identity::Domain::Aggregates::User.create!(name: "Client User", email: "client@example.com", access_state: :active)

    allow(user_repository).to receive(:find_by_email).with("client@example.com").and_return(user)
    allow(account_repository).to receive(:find_by_user_and_role).with(user, :client).and_return([ workspace ])

    result = described_class.call(
      email: "client@example.com",
      role: :client,
      user_repository: user_repository,
      account_repository: account_repository
    )

    expect(result.data[:account]).to eq(workspace)
  end

  it "returns nil when the workspace user cannot be resolved" do
    user_repository = class_double(Identity::Domain::Repositories::UserRepository).as_stubbed_const
    account_repository = instance_double(Identity::Adapters::Persistence::Account::Repository)

    allow(user_repository).to receive(:find_by_email).and_return(nil)

    result = described_class.call(
      email: "client@example.com",
      role: :client,
      user_repository: user_repository,
      account_repository: account_repository
    )

    expect(result.data[:account]).to be_nil
  end

  def build_client_account(email: "client@example.com", name: "Client")
    Identity::Domain::Aggregates::Account.create!(name: name, email: email, role: :client)
  end
end
