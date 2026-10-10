require "rails_helper"
require "rake"

RSpec.describe "payments rake tasks" do
  before(:all) do
    Rake::Task.define_task(:environment)
    load Rails.root.join("lib/tasks/payments.rake")
  end

  around do |example|
    original_env = {
      "APP_PORT" => ENV["APP_PORT"],
      "APP_HOST_PORT" => ENV["APP_HOST_PORT"],
      "WEBHOOK_URL" => ENV["WEBHOOK_URL"],
      "PROJECT_ID" => ENV["PROJECT_ID"],
      "PROVIDER" => ENV["PROVIDER"],
      "EVENT_ID" => ENV["EVENT_ID"],
      "TYPE" => ENV["TYPE"],
      "PAYMENT_ID" => ENV["PAYMENT_ID"],
      "PROVIDER_REFERENCE" => ENV["PROVIDER_REFERENCE"],
      "AMOUNT_CENTS" => ENV["AMOUNT_CENTS"],
      "DEMO_FAIL_ONCE" => ENV["DEMO_FAIL_ONCE"],
      "DEMO_FAIL_ALWAYS" => ENV["DEMO_FAIL_ALWAYS"]
    }

    example.run
  ensure
    original_env.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    Rake::Task["payments:simulate_webhook"].reenable
    Rake::Task["payments:replay_webhook_event"].reenable
    Rake::Task["payments:replay_failed_webhook_events"].reenable
  end

  def default_webhook_url
    "http://localhost:#{ENV.fetch("APP_HOST_PORT", ENV.fetch("APP_PORT", 3000))}/payments/webhooks/fake/events"
  end

  it "defaults to localhost and forwards env vars to the simulator" do
    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "sends a signed fake webhook with a succeeded default type" do
    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "resolves the payment from a project id when provided" do
    client = workspace_account(:client, name: "Client", email: "project-client@example.com")
    pm = workspace_account(:pm, name: "PM", email: "project-pm@example.com")
     project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 77_000,
      currency: "USD",
      provider_reference: "fake-project-ref"
    )

    Payments::Domain::Entities::PaymentAttempt.create!(
      payment: payment,
      status: :submitted,
      provider: payment.provider,
      idempotency_key: payment.idempotency_key,
      provider_reference: payment.provider_reference,
      request_payload: { "payment_id" => payment.id },
      response_payload: { "status" => "accepted" }
    )

    ENV["PROJECT_ID"] = project.id.to_s

    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: payment.id,
      provider_reference: "fake-project-ref",
      amount_cents: 77_000
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "falls back to the most recent payment when the project has no active payment" do
    client = workspace_account(:client, name: "Client", email: "fallback-client@example.com")
    pm = workspace_account(:pm, name: "PM", email: "fallback-pm@example.com")
     project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    historical_payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 88_000,
      currency: "USD",
      provider_reference: "fake-historical-ref"
    )

    ENV["PROJECT_ID"] = project.id.to_s

    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: historical_payment.id,
      provider_reference: "fake-historical-ref",
      amount_cents: 88_000
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "treats blank env vars like unset values" do
    ENV["WEBHOOK_URL"] = ""
    ENV["PROVIDER"] = ""
    ENV["EVENT_ID"] = ""
    ENV["TYPE"] = ""
    ENV["PAYMENT_ID"] = ""
    ENV["PROVIDER_REFERENCE"] = ""
    ENV["AMOUNT_CENTS"] = ""

    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "uses an explicit webhook url when provided" do
    ENV["WEBHOOK_URL"] = "http://example.com/webhooks"

    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: "http://example.com/webhooks",
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "forwards the demo fail-once flag to the webhook simulator" do
    ENV["DEMO_FAIL_ONCE"] = "1"

    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000",
      demo_fail_once: true
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "forwards the demo fail-always flag to the webhook simulator" do
    ENV["DEMO_FAIL_ALWAYS"] = "1"

    expect(Payments::Adapters::Outbound::Webhooks::WebhookSimulator).to receive(:call).with(
      webhook_url: default_webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000",
      demo_fail_always: true
    ).and_return(Core::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "replays a single event by provider event id" do
    payment = Payments::Domain::Aggregates::Payment.create!(
       project: Project.create!(owner: workspace_account(:client, name: "Client", email: "replay-client@example.com"), participant: workspace_account(:pm, name: "PM", email: "replay-pm@example.com"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-replay-ref"
    )

    event = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_replay",
      event_type: "payment.succeeded",
      payment: payment,
      project: payment.project,
      payload: {
        "id" => "evt_replay",
        "type" => "payment.succeeded",
        "data" => { "payment_id" => payment.id, "provider_reference" => payment.provider_reference, "amount_cents" => payment.amount_cents }
      },
      signature: "signature",
      status: :failed,
      received_at: Time.current,
      error_message: "Transient failure",
      processing_attempts_count: 1
    )

    ENV["EVENT_ID"] = event.provider_event_id

    expect(Payments::Adapters::Inbound::Webhooks::Event::Job).to receive(:perform_later).with(event.id)

    Rake::Task["payments:replay_webhook_event"].invoke
  end

  it "replays failed or received events" do
    failed = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_failed",
      event_type: "payment.succeeded",
      payload: { "id" => "evt_failed", "type" => "payment.succeeded", "data" => {} },
      status: :failed,
      received_at: Time.current,
      error_message: "Transient failure"
    )

    received = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_received",
      event_type: "payment.succeeded",
      payload: { "id" => "evt_received", "type" => "payment.succeeded", "data" => {} },
      status: :received,
      received_at: Time.current
    )

    expect(Payments::Adapters::Inbound::Webhooks::Event::Job).to receive(:perform_later).with(failed.id).ordered
    expect(Payments::Adapters::Inbound::Webhooks::Event::Job).to receive(:perform_later).with(received.id).ordered

    Rake::Task["payments:replay_failed_webhook_events"].invoke
  end
end
