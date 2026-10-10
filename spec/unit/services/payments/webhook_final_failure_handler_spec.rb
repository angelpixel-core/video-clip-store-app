require "rails_helper"

RSpec.describe Payments::Adapters::Inbound::Webhooks::Event::FinalFailureHandler do
  def build_payment(status: :processing)
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: status,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )
  end

  def build_payment_attempt(payment)
    Payments::Domain::Entities::PaymentAttempt.create!(
      payment: payment,
      status: :submitted,
      provider: payment.provider,
      idempotency_key: payment.idempotency_key,
      provider_reference: payment.provider_reference,
      request_payload: {
        payment_id: payment.id,
        order_id: payment.project_id,
        amount_cents: payment.amount_cents,
        currency: payment.currency,
        idempotency_key: payment.idempotency_key
      },
      response_payload: {
        provider_reference: payment.provider_reference,
        status: "accepted"
      }
    )
  end

  def build_event(payment:, event_id: "evt_123", demo_fail_once: false)
    Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: event_id,
      event_type: "payment.succeeded",
      payment: payment,
      project: payment.project,
      payload: {
        "id" => event_id,
        "type" => "payment.succeeded",
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents,
          "demo_fail_once" => demo_fail_once
        }
      },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )
  end

  it "finalizes the payment and creates a final failure notification once" do
    payment = build_payment
    build_payment_attempt(payment)
    event = build_event(payment: payment, event_id: "evt_failed_final")
    event.record_processing_attempt!

    result = described_class.call(payment_webhook_event_id: event.id, error: Payments::Domain::Errors::DemoTransientFailure.new("Demo transient webhook failure."))

    expect(result).to be_success
    expect(result.data[:applied]).to eq(true)

    payment.reload
    event.reload

    expect(payment.status).to eq("failed")
    expect(payment.failed_at).to be_present
    expect(payment.confirmed_at).to be_nil
    expect(event.status).to eq("failed")
    expect(event.error_message).to eq("Demo transient webhook failure.")
    expect(event.last_failure_message).to eq("Demo transient webhook failure.")
    expect(event.failure_reason_code).to eq("demo_transient_failure")
    expect(event.processing_attempts_count).to eq(1)
    expect(event.processing_attempts.first.status).to eq("failed")

    intent = payment.payment_notification_intents.find_by(event_type: "payment.failed_final")

    expect(intent).to be_present
    expect(intent.from_status).to eq("processing")
    expect(intent.to_status).to eq("failed")
    expect(intent.payload["failure_message"]).to eq("Demo transient webhook failure.")
    expect(intent.payload["failure_class"]).to eq("Payments::Domain::Errors::DemoTransientFailure")
    expect(intent.payload["failure_reason_code"]).to eq("demo_transient_failure")

    expect do
      described_class.call(payment_webhook_event_id: event.id, error: Payments::Domain::Errors::DemoTransientFailure.new("Demo transient webhook failure."))
    end.not_to change { payment.payment_notification_intents.where(event_type: "payment.failed_final").count }
  end

  it "does nothing when the payment is already terminal" do
    payment = build_payment(status: :failed)
    build_payment_attempt(payment)
    event = build_event(payment: payment, event_id: "evt_failed_final")
    event.record_processing_attempt!

    result = described_class.call(payment_webhook_event_id: event.id, error: StandardError.new("boom"))

    expect(result).to be_success
    expect(result.data[:applied]).to eq(false)
    expect(result.data[:reason]).to eq(:stale_payment_state)
    expect(payment.payment_notification_intents.count).to eq(0)
  end
end
