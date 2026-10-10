require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::Membership::MembershipRecord do
  it "normalizes and validates a membership role" do
    account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
    user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)

    membership = described_class.new(user: user, account: account, role: " CLIENT ")

    expect(membership).to be_valid
    expect(membership.role).to eq("client")
    expect(membership).to be_client
  end
end
