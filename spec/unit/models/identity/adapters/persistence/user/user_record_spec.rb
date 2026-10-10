require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::User::UserRecord do
  it "normalizes and validates a user" do
    user = described_class.new(name: "Alice", email: "  ALICE@example.com  ", access_state: " active ", preferred_locale: "es", timezone: "UTC")

    expect(user).to be_valid
    expect(user.email).to eq("alice@example.com")
    expect(user.access_state).to eq("active")
    expect(user).to be_active
  end
end
