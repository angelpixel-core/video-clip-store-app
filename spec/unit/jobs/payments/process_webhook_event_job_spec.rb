require "rails_helper"

RSpec.describe Payments::Adapters::Inbound::Webhooks::Event::Job do
  include ActiveJob::TestHelper

  it "uses the shared bounded retry policy" do
    expect(described_class::MAX_RETRY_ATTEMPTS).to eq(Payments::Domain::Policies::RetryPolicy::MAX_ATTEMPTS)
  end

  it "delegates exhausted retries to the final failure handler" do
    error = Payments::Domain::Errors::DemoTransientFailure.new("boom")

    expect(Payments::Adapters::Inbound::Webhooks::Event::FinalFailureHandler).to receive(:call).with(
      payment_webhook_event_id: 123,
      error: error
    )

    described_class.handle_retry_exhaustion(payment_webhook_event_id: 123, error: error)
  end

  it "keeps the retry exhaustion hook wired to the final failure handler" do
    error = Payments::Domain::Errors::DemoTransientFailure.new("boom")

    job = described_class.new(123)
    job.executions = described_class::MAX_RETRY_ATTEMPTS
    expect(job.executions).to eq(described_class::MAX_RETRY_ATTEMPTS)

    expect(Payments::Adapters::Inbound::Webhooks::Event::FinalFailureHandler).to receive(:call).with(
      payment_webhook_event_id: 123,
      error: error
    )

    described_class.handle_retry_exhaustion(payment_webhook_event_id: job.arguments.first, error: error)
  end

  it "delegates to the payment event handler when the event exists" do
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
      provider_reference: "fake-abc123"
    )

    event = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_123",
      event_type: "payment.succeeded",
      payment: payment,
      project: payment.project,
      payload: {
        "id" => "evt_123",
        "type" => "payment.succeeded",
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents
        }
      },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )

    service = instance_double(Payments::Adapters::Inbound::Webhooks::Event::Handler)
    expect(Payments::Adapters::Inbound::Webhooks::Event::Handler).to receive(:call).with(event: event).and_return(service)

    described_class.perform_now(event.id)
  end

  it "does nothing when the event is missing" do
    expect(Payments::Adapters::Inbound::Webhooks::Event::Handler).not_to receive(:call)

    described_class.perform_now(-1)
  end

  it "retries deadlocks" do
    allow(Payments::Domain::Entities::PaymentWebhookEvent).to receive(:find_by).and_raise(ActiveRecord::Deadlocked)

    assert_enqueued_jobs 1 do
      described_class.perform_now(123)
    end
  end

  it "retries the demo transient failure and eventually processes the event" do
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
      provider_reference: "fake-abc123"
    )

    event = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_demo_retry",
      event_type: "payment.succeeded",
      payment: payment,
      project: payment.project,
      payload: {
        "id" => "evt_demo_retry",
        "type" => "payment.succeeded",
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents,
          "demo_fail_once" => true
        }
      },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )

    perform_enqueued_jobs do
      described_class.perform_later(event.id)
    end

    event.reload

    expect(event.status).to eq("processed")
    expect(event.processing_attempts_count).to eq(2)
    expect(event.last_failure_message).to eq(Payments::Adapters::Inbound::Webhooks::Event::Handler::DEMO_FAILURE_MESSAGE)
    expect(event.processing_attempts.order(:attempt_number).pluck(:status)).to eq(%w[failed succeeded])
    expect(payment.reload.status).to eq("succeeded")
  end
end
