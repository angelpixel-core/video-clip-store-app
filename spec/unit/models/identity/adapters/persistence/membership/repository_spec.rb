require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::Membership::Repository do
  it "finds memberships by user, account, and pair" do
    account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
    user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
    membership = Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

    repo = described_class.new

    expect(repo.find_by_user(user)).to contain_exactly(membership)
    expect(repo.find_by_account(account)).to contain_exactly(membership)
    expect(repo.find_by_user_and_account(user, account)).to eq(membership)
  end

  it "persists membership lifecycle changes" do
    account = Identity::Domain::Aggregates::Account.create!(name: "Workspace", email: "workspace@example.com", role: :client)
    user = Identity::Domain::Aggregates::User.create!(name: "Alice", email: "alice@example.com", access_state: :active)
    membership = Identity::Domain::Aggregates::Membership.create!(user: user, account: account, role: :client)

    membership.role = :pm

    described_class.new.save(membership)

    expect(membership.reload).to be_pm
  end
end
