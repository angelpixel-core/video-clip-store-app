require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::User::Repository do
  describe "#find_by_email_and_role" do
    it "returns the role-specific user model" do
      account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
      user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
      Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

      expect(described_class.new.find_by_email_and_role("alice@example.com", :client)).to eq(user)
    end
  end

  describe "#find_by_role" do
    it "returns the matching user scope" do
      account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
      user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
      Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

      expect(described_class.new.find_by_role(:client)).to include(user)
    end
  end

  describe "#save" do
    it "persists lifecycle changes" do
      user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
      user.access_state = :suspended

      described_class.new.save(user)

      expect(user.reload).to be_suspended
    end
  end
end
