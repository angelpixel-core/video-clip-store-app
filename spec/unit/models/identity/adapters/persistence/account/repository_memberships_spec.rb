require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::Account::Repository do
  describe "#find_by_user" do
    it "returns accounts linked to the user through memberships" do
      account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
      user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
      Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

      expect(described_class.new.find_by_user(user)).to contain_exactly(account)
    end
  end

  describe "#find_by_user_and_role" do
    it "returns role-matched accounts linked to the user through memberships" do
      account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
      user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
      Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

      expect(described_class.new.find_by_user_and_role(user, :client)).to contain_exactly(account)
    end
  end
end
