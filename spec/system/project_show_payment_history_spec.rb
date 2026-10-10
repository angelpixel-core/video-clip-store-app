require "rails_helper"

def switch_workspace_to(mode)
  find(".account-menu-trigger").click
  click_button "Switch to #{mode}"
end

RSpec.describe "Project show payment history", type: :system, js: true do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"]
    original_pm = ENV["DEFAULT_PM_WORKSPACE_EMAIL"]

    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com"

    example.run
  ensure
    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = original_client
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = original_pm
  end

  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "shows payment history to the pm and keeps it hidden from the client workspace" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :processing,
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
      request_payload: { "payment_id" => payment.id },
      response_payload: { "status" => "accepted" }
    )

    event = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_123",
      event_type: "payment.succeeded",
      payment: payment,
      project: project,
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
      status: :processed,
      received_at: 1.minute.ago,
      processed_at: Time.current,
      processing_attempts_count: 1,
      last_attempted_at: Time.current
    )

    Payments::Domain::Entities::PaymentWebhookEventAttempt.create!(
      payment_webhook_event: event,
      attempt_number: 1,
      status: :succeeded,
      started_at: 1.minute.ago,
      finished_at: Time.current
    )

    visit order_path(project)

    expect(page).to have_no_css("#payment-history", visible: :visible)

    switch_workspace_to("PM")

    expect(page).to have_css("#payment-history", visible: :visible)
    expect(page).to have_css("#payment-history", text: "Webhook events and attempts")
    expect(page).to have_css("#payment-history", text: "payment.succeeded")
    expect(page).to have_css("#payment-history", text: "Event: evt_123")
    expect(page).to have_css("#payment-history", text: "Payment ##{payment.id}")
    expect(page).to have_css("#payment-history", text: "Project ##{project.id}")
    expect(page).to have_css("#payment-history", text: "Attempts: 1")
    expect(page).to have_css("#payment-history", text: "submitted")
    expect(page).to have_css("#payment-history", text: "PROCESSED")
    expect(page).to have_css("#payment-history", text: "Attempt #1")
  end

  it "shows confirmed when the payment has been successfully processed" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Beta", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-xyz789"
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

    event = Payments::Domain::Entities::PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_456",
      event_type: "payment.succeeded",
      payment: payment,
      project: project,
      payload: {
        "id" => "evt_456",
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

    Payments::Adapters::Inbound::Webhooks::Event::Job.perform_now(event.id)

    visit order_path(project)

    switch_workspace_to("PM")

    expect(page).to have_css("#payment-history", text: "succeeded")
    expect(page).to have_css("#payment-history", text: "Confirmed")
    expect(page).to have_css("#payment-history", text: "Event: evt_456")
    expect(page).to have_css("#payment-history", text: "Payment ##{payment.id}")
    expect(page).to have_css("#payment-history", text: "Project ##{project.id}")
    expect(page).to have_css("#payment-history", text: "Attempts: 1")
    expect(page).to have_css("#payment-history", text: "Attempt #1")
    expect(page).to have_css("#payment-history", text: payment.reload.confirmed_at.to_fs(:short))
  end
end
