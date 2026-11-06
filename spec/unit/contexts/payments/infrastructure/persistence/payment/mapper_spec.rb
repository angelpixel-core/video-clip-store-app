require "rails_helper"

RSpec.describe Payments::Infrastructure::Persistence::Payment::Mapper do
  it "converts a record to domain and writes back to record" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    record = Payments::Infrastructure::Persistence::Payment::PaymentRecord.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 20_000,
      currency: "USD",
      provider_reference: "rec-map-123"
    )

    mapper = described_class.new
    domain = mapper.to_domain(record)

    expect(domain.id).to eq(record.id)
    expect(domain.project_id).to eq(record.project_id)
    expect(domain.amount_cents).to eq(20_000)

    back_to_record = mapper.to_record(domain)
    expect(back_to_record.id).to eq(record.id)
    expect(back_to_record.amount_cents).to eq(20_000)
  end
end
