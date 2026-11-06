require "rails_helper"

RSpec.describe Identity::Domain::Aggregates::Account do
  it "tracks memberships and user roles for the workspace" do
    account = described_class.create!(name: "Workspace", email: "workspace@example.com", role: :client)
    user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
    membership = Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

    expect(account.memberships).to contain_exactly(membership)
    expect(account.users).to contain_exactly(user)
    expect(account.membership_for(user)).to eq(membership)
    expect(account.role_for(user)).to eq(Identity::Domain::ValueObjects::Role.new(:client))
    expect(account.users_with_role(:client)).to contain_exactly(user)
  end
end
