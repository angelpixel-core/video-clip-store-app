require "rails_helper"

RSpec.describe Payments::Adapters::Inbound::Webhooks::Event::Handler do
  def build_payment(status: :processing)
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: status,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

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

    payment
  end

  def build_event(payment:, event_type: "payment.succeeded", event_id: "evt_123", demo_fail_once: false, demo_fail_always: false)
    Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: event_id,
      event_type: event_type,
      payment: payment,
      project: payment.project,
      payload: {
        "id" => event_id,
        "type" => event_type,
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents,
          "demo_fail_once" => demo_fail_once,
          "demo_fail_always" => demo_fail_always
        }
      },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )
  end

  it "processes a succeeded event once" do
    payment = build_payment
    event = build_event(payment: payment)

    result = described_class.(event: event)

    expect(result).to be_success
    expect(result.data[:applied]).to eq(true)

    payment.reload
    event.reload

    expect(payment.status).to eq("succeeded")
    expect(payment.confirmed_at).to be_present
    expect(payment.payment_attempts.first.status).to eq("succeeded")
    expect(payment.payment_notification_intents.count).to eq(1)
    expect(payment.payment_notification_intents.first.event_type).to eq("payment.succeeded")
    expect(event.status).to eq("processed")
    expect(event.processed_at).to be_present
    expect(event.error_message).to be_nil
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_attempted_at).to be_present
    expect(event.processing_attempts.count).to eq(1)
    expect(event.processing_attempts.first.status).to eq("succeeded")
  end

  it "is idempotent when the same processed event is handled again" do
    payment = build_payment
    event = build_event(payment: payment)

    described_class.(event: event)

    expect do
      described_class.(event: event.reload)
    end.not_to change { payment.reload.status }

    expect(event.reload.status).to eq("processed")
    expect(event.processed_at).to be_present
  end

  it "marks unknown event types as failed" do
    payment = build_payment
    event = build_event(payment: payment, event_type: "payment.reopened")

    result = described_class.(event: event)

    expect(result).to be_failure
    expect(result.code).to eq(:unknown_event_type)
    expect(event.reload.status).to eq("failed")
    expect(event.error_message).to eq("Unsupported payment webhook event type.")
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_failure_message).to eq("Unsupported payment webhook event type.")
    expect(event.processing_attempts.first.status).to eq("failed")
    expect(payment.payment_notification_intents.count).to eq(0)
    expect(payment.reload.status).to eq("processing")
  end

  it "fails once for the demo retry flag and succeeds on the next attempt" do
    payment = build_payment
    event = build_event(payment: payment, demo_fail_once: true)

    expect { described_class.(event: event) }.to raise_error(Payments::Domain::Errors::DemoTransientFailure, Payments::Adapters::Inbound::Webhooks::Event::Handler::DEMO_FAILURE_MESSAGE)
    expect(event.reload.status).to eq("failed")
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_failure_message).to eq(Payments::Adapters::Inbound::Webhooks::Event::Handler::DEMO_FAILURE_MESSAGE)
    expect(event.processing_attempts.first.status).to eq("failed")
    expect(payment.payment_notification_intents.count).to eq(0)

    second_result = described_class.(event: event.reload)

    expect(second_result).to be_success
    expect(second_result.data[:applied]).to eq(true)
    expect(event.reload.status).to eq("processed")
    expect(event.processing_attempts_count).to eq(2)
    expect(event.processing_attempts.order(:attempt_number).pluck(:status)).to eq(%w[failed succeeded])
    expect(payment.payment_notification_intents.count).to eq(1)
    expect(payment.reload.status).to eq("succeeded")
  end

  it "fails on every attempt for the demo always-fail flag" do
    payment = build_payment
    event = build_event(payment: payment, demo_fail_always: true)

    expect { described_class.(event: event) }.to raise_error(Payments::Domain::Errors::DemoTransientFailure, Payments::Adapters::Inbound::Webhooks::Event::Handler::DEMO_FAILURE_MESSAGE)
    expect(event.reload.status).to eq("failed")
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_failure_message).to eq(Payments::Adapters::Inbound::Webhooks::Event::Handler::DEMO_FAILURE_MESSAGE)

    expect { described_class.(event: event.reload) }.to raise_error(Payments::Domain::Errors::DemoTransientFailure, Payments::Adapters::Inbound::Webhooks::Event::Handler::DEMO_FAILURE_MESSAGE)
    expect(event.reload.status).to eq("failed")
    expect(event.processing_attempts_count).to eq(2)
    expect(event.processing_attempts.order(:attempt_number).pluck(:status)).to eq(%w[failed failed])
    expect(payment.payment_notification_intents.count).to eq(0)
    expect(payment.reload.status).to eq("processing")
  end

  it "ignores an out-of-order failure after success" do
    payment = build_payment
    success_event = build_event(payment: payment, event_type: "payment.succeeded", event_id: "evt_success")
    failure_event = build_event(payment: payment, event_type: "payment.failed", event_id: "evt_failure")

    described_class.(event: success_event)
    result = described_class.(event: failure_event)

    expect(result).to be_success
    expect(result.data[:applied]).to eq(false)
    expect(result.data[:reason]).to eq(:stale_payment_state)
    expect(payment.reload.status).to eq("succeeded")
    expect(failure_event.reload.status).to eq("processed")
    expect(failure_event.processed_at).to be_present
    expect(failure_event.processing_attempts_count).to eq(1)
    expect(failure_event.processing_attempts.first.status).to eq("succeeded")
    expect(payment.payment_notification_intents.count).to eq(1)
  end

  it "processes a refunded event and marks the refund as refunded" do
    payment = build_payment
    refund = payment.refunds.create!(
      payment_method_reference: payment.payment_method_reference || Payments::Domain::Entities::PaymentMethodReference.create!(payment: payment, provider: payment.provider, method_type: "card", reference: "pm_ref_123"),
      provider: payment.provider,
      provider_reference: "refund-123",
      status: :refund_processing,
      amount_cents: payment.amount_cents,
      reason: "approved_by_operator"
    )
    event = build_event(payment: payment, event_type: "payment.refunded", event_id: "evt_refunded")
    event.update!(payload: event.payload.deep_merge("type" => "payment.refunded", "data" => { "refund_id" => refund.id, "provider_reference" => refund.provider_reference }))

    result = described_class.(event: event)

    expect(result).to be_success
    expect(result.data[:applied]).to eq(true)
    expect(result.data[:refund].status).to eq("refunded")
    expect(payment.reload.status).to eq("refunded")
    expect(refund.reload.status).to eq("refunded")
    expect(payment.payment_notification_intents.last.event_type).to eq("payment.refunded")
  end
end
