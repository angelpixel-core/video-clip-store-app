require "rails_helper"

RSpec.describe Identity::Domain::Aggregates::Membership do
  it "normalizes the role and exposes capabilities" do
    account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
    user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)

    membership = described_class.create!(user: user, account: account, role: " PM ")

    expect(membership.role).to eq("pm")
    expect(membership.role_object).to eq(Identity::Domain::ValueObjects::Role.new(:pm))
    expect(membership.capabilities).to include(:accept_project, :complete_project)
  end
end
