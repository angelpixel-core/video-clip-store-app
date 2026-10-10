require "rails_helper"

RSpec.describe Payments::Application::Handlers::DispatchPaymentNotificationJob do
  it "dispatches a pending intent and marks it sent" do
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: Project.create!(owner: workspace_account(:client, email: "client@example.com", name: "Client"), participant: workspace_account(:pm, email: "pm@example.com", name: "PM"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :pending,
      scheduled_at: Time.current
    )

    expect(Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer).to receive(:payment_status_changed).with(intent, recipient_role: :client).and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))
    expect(Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer).to receive(:payment_status_changed).with(intent, recipient_role: :pm).and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))

    described_class.perform_now(intent.id)

    expect(intent.reload.sent?).to eq(true)
    expect(intent.processed_at).to be_present
    expect(intent.last_error).to be_nil
  end

  it "marks the intent failed when dispatch raises" do
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: Project.create!(owner: workspace_account(:client, email: "client@example.com", name: "Client"), participant: workspace_account(:pm, email: "pm@example.com", name: "PM"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :pending,
      scheduled_at: Time.current
    )

    allow(Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer).to receive(:payment_status_changed).and_raise(StandardError, "boom")

    expect do
      described_class.perform_now(intent.id)
    end.to raise_error(StandardError, "boom")

    expect(intent.reload.failed?).to eq(true)
    expect(intent.attempts_count).to eq(1)
    expect(intent.last_error).to eq("boom")
  end

  it "does nothing for missing or already sent intents" do
    expect(Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer).not_to receive(:payment_status_changed)

    described_class.perform_now(-1)

    payment = Payments::Domain::Aggregates::Payment.create!(
      project: Project.create!(owner: workspace_account(:client, email: "client@example.com", name: "Client"), participant: workspace_account(:pm, email: "pm@example.com", name: "PM"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :sent,
      scheduled_at: Time.current,
      processed_at: Time.current
    )

    expect(Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer).not_to receive(:payment_status_changed)

    described_class.perform_now(intent.id)
  end
end
