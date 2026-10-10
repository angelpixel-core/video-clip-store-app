require "rails_helper"

RSpec.describe Identity::Domain::Aggregates::Account do
  it "normalizes and validates client accounts" do
    account = described_class.new(name: "Client", email: "  CLIENT@example.com  ", role: :client)

    expect(account).to be_valid
    expect(account.email).to eq("client@example.com")
    expect(account).to be_client
  end

  it "normalizes and validates pm accounts" do
    account = described_class.new(name: "PM", email: "  PM@example.com  ", role: :pm)

    expect(account).to be_valid
    expect(account.email).to eq("pm@example.com")
    expect(account).to be_pm
  end
end
