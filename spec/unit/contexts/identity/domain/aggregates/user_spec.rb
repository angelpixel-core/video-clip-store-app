require "rails_helper"

RSpec.describe Identity::Domain::Aggregates::User do
  it "tracks memberships and roles for accounts" do
    account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
    user = described_class.create!(name: "Alice", email: "alice@example.com", access_state: :active)
    membership = Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

    expect(user.memberships).to contain_exactly(membership)
    expect(user.accounts).to contain_exactly(account)
    expect(user.member_of?(account)).to be(true)
    expect(user.role_for(account)).to eq(Identity::Domain::ValueObjects::Role.new(:client))
    expect(user.roles).to contain_exactly(Identity::Domain::ValueObjects::Role.new(:client))
  end
end
