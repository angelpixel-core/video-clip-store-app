require "rails_helper"

RSpec.describe Payments::Adapters::Outbound::Gateways::Fake do
  it "returns a success result for a valid payment" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :pending,
      provider: "fake",
      idempotency_key: "payment-key",
      amount_cents: 10_000,
      currency: "usd"
    )

    result = described_class.(payment: payment)

    expect(result).to be_success
    expect(result.data[:provider_reference]).to eq("fake-payment-key")
    expect(result.data[:request_payload]).to include(order_id: project.id)
    expect(result.data[:response_payload]).to eq(
      {
        provider_reference: "fake-payment-key",
        status: "accepted"
      }
    )
  end

  it "returns a failure for a zero amount payment" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :pending,
      provider: "fake",
      idempotency_key: "payment-key-zero",
      amount_cents: 0,
      currency: "usd"
    )

    result = described_class.(payment: payment)

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_amount)
  end
end
