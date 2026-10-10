require "rails_helper"

RSpec.describe Payments::Domain::Entities::PaymentNotificationIntent do
  it "enqueues the dispatcher job after commit when created" do
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: Project.create!(owner: workspace_account(:client, name: "Client"), participant: workspace_account(:pm, name: "PM"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = described_class.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :pending,
      scheduled_at: Time.current
    )

    expect(Payments::Application::Handlers::DispatchPaymentNotificationJob).to receive(:perform_later).with(intent.id)

    intent.send(:enqueue_dispatch_job)
  end

  it "normalizes payload and status" do
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: Project.create!(owner: workspace_account(:client, name: "Client"), participant: workspace_account(:pm, name: "PM"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = described_class.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: nil,
      scheduled_at: nil
    )

    expect(intent.status).to eq("pending")
    expect(intent.payload).to eq({ "payment_id" => payment.id })
    expect(intent.scheduled_at).to be_present
  end
end
