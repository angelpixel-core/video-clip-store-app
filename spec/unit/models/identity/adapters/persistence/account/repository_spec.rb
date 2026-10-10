require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::Account::Repository do
  describe "#find_by_email_and_role" do
    it "returns the role-specific account model" do
      client = workspace_account(:client, email: "client-1@example.com", name: "Client")
      pm = workspace_account(:pm, email: "pm-1@example.com", name: "PM")

      expect(described_class.new.find_by_email_and_role("client-1@example.com", :client)).to eq(client.becomes(Identity::Domain::Aggregates::Account))
      expect(described_class.new.find_by_email_and_role("pm-1@example.com", :pm)).to eq(pm.becomes(Identity::Domain::Aggregates::Account))
    end
  end

  describe "#find_by_role" do
    it "returns the role scope" do
      workspace_account(:client, email: "client-2@example.com", name: "Client")
      workspace_account(:pm, email: "pm-2@example.com", name: "PM")

      expect(described_class.new.find_by_role(:client)).to all(be_a(Identity::Domain::Aggregates::Account))
      expect(described_class.new.find_by_role(:pm)).to all(be_a(Identity::Domain::Aggregates::Account))
    end
  end
end
