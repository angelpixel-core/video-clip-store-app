require "rails_helper"

RSpec.describe Payments::Infrastructure::Persistence::Payment::PaymentRecord do
  it "is an ActiveRecord model mapping to the payments table" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    record = described_class.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 20_000,
      currency: "USD",
      provider_reference: "rec-123"
    )

    expect(record).to be_persisted
    expect(record.project).to eq(project)
    expect(record.status).to eq("succeeded")
    expect(record.succeeded?).to be(true)
  end
end

