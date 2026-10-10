require "rails_helper"

RSpec.describe Payments::Domain::Repositories::PaymentRepository do
  def build_payment(provider_reference: "fake-abc123")
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: Project.create!(
        owner: workspace_account(:client, name: "Client"),
        participant: workspace_account(:pm, name: "PM"),
        name: "Project",
        raw_footage_url: "https://example.com/raw.mov",
        status: :pending
      ),
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: provider_reference
    )
    payment
  end

  it "finds a payment by id" do
    payment = build_payment

    expect(described_class.find_by_id(payment.id)).to eq(payment)
  end

  it "finds a payment by provider reference" do
    payment = build_payment

    expect(described_class.find_by_provider_reference(payment.provider_reference)).to eq(payment)
  end
end
