require "rails_helper"

RSpec.describe Payments::Adapters::Persistence::Webhook::Event::Repository do
  def build_payment
    Payments::Domain::Aggregates::Payment.create!(
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
      provider_reference: "fake-abc123"
    )
  end

  it "upserts a received webhook event" do
    payment = build_payment

    event, created = described_class.upsert_received_event(
      provider: "fake",
      event_id: "evt_123",
      event_type: "payment.succeeded",
      payload: {
        "id" => "evt_123",
        "type" => "payment.succeeded",
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents
        }
      },
      signature: "signature"
    )

    expect(created).to eq(true)
    expect(event).to be_persisted
    expect(event.provider).to eq("fake")
    expect(event.provider_event_id).to eq("evt_123")
    expect(event.event_type).to eq("payment.succeeded")
  end

  it "finds an event by id" do
    event = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_123",
      event_type: "payment.succeeded",
      payload: { "id" => "evt_123", "type" => "payment.succeeded", "data" => {} },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )

    expect(described_class.find_by_id(event.id)).to eq(event)
  end
end
