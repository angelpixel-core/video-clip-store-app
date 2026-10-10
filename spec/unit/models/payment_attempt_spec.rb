require "rails_helper"

RSpec.describe Payments::Domain::Entities::PaymentAttempt do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a payment and requires unique idempotency keys" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :pending,
      provider: "fake",
      idempotency_key: "payment-key",
      amount_cents: 10_000,
      currency: "usd"
    )

    attempt = described_class.create!(
      payment: payment,
      status: :pending,
      provider: "fake",
      idempotency_key: "attempt-key",
      request_payload: { "amount_cents" => 10_000 },
      response_payload: { "status" => "pending" }
    )

    expect(attempt.payment).to eq(payment)

    duplicate = described_class.new(
      payment: payment,
      status: :submitted,
      provider: "fake",
      idempotency_key: "attempt-key",
      request_payload: { "amount_cents" => 10_000 },
      response_payload: { "status" => "pending" }
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:idempotency_key]).to be_present
  end
end
