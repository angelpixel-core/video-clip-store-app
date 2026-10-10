require "rails_helper"

RSpec.describe "Payments webhooks requests" do
  include ActiveJob::TestHelper

  def webhook_body(event_id: "evt_123", type: "payment.succeeded", payment_id:, provider_reference:)
    {
      id: event_id,
      type: type,
      data: {
        payment_id: payment_id,
        provider_reference: provider_reference,
        amount_cents: 50_000
      }
    }.to_json
  end

  def webhook_signature(body)
    OpenSSL::HMAC.hexdigest("SHA256", Payments::Adapters::Inbound::Webhooks::Event::Ingest::WEBHOOK_SECRET, body)
  end

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

  it "accepts a valid provider event" do
    payment = build_payment
    body = webhook_body(payment_id: payment.id, provider_reference: payment.provider_reference)

    expect do
      perform_enqueued_jobs do
        post payments_webhook_events_path(provider: "fake"), params: body, headers: {
          "CONTENT_TYPE" => "application/json",
          "X-Payment-Signature" => webhook_signature(body)
        }
      end
    end.to change(Payments::Domain::Entities::PaymentWebhookEvent, :count).by(1)

    expect(response).to have_http_status(:accepted)

    event = Payments::Domain::Entities::PaymentWebhookEvent.order(:created_at).last
    expect(event.provider).to eq("fake")
    expect(event.provider_event_id).to eq("evt_123")
    expect(event.event_type).to eq("payment.succeeded")
    expect(event.payment_id).to eq(payment.id)
    expect(event.project_id).to eq(payment.project_id)
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_attempted_at).to be_present
    expect(event.processing_attempts.count).to eq(1)
    expect(event.processing_attempts.first.status).to eq("succeeded")
    expect(event.payload).to include("data" => hash_including("provider_reference" => "fake-abc123"))
    expect(event.status).to eq("processed")
    expect(event.processed_at).to be_present
    expect(payment.payment_notification_intents.count).to eq(1)
    expect(payment.payment_notification_intents.first.event_type).to eq("payment.succeeded")

    payment.reload
    expect(payment.status).to eq("succeeded")
    expect(payment.confirmed_at).to be_present
    expect(payment.payment_attempts.first.status).to eq("succeeded")
  end

  it "returns ok for a duplicate provider event" do
    payment = build_payment
    body = webhook_body(payment_id: payment.id, provider_reference: payment.provider_reference)
    headers = {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => webhook_signature(body)
    }

    perform_enqueued_jobs do
      post payments_webhook_events_path(provider: "fake"), params: body, headers: headers
    end
    expect do
      perform_enqueued_jobs do
        post payments_webhook_events_path(provider: "fake"), params: body, headers: headers
      end
    end.not_to change(Payments::Domain::Entities::PaymentWebhookEvent, :count)

    expect(response).to have_http_status(:ok)
    expect(Payments::Domain::Entities::PaymentWebhookEvent.order(:created_at).last.status).to eq("processed")
  end

  it "rejects an invalid signature" do
    payment = build_payment
    body = webhook_body(payment_id: payment.id, provider_reference: payment.provider_reference)

    post payments_webhook_events_path(provider: "fake"), params: body, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => "bad-signature"
    }

    expect(response).to have_http_status(:unauthorized)
    expect(Payments::Domain::Entities::PaymentWebhookEvent.count).to eq(0)
  end

  it "rejects malformed json" do
    body = "{not-json"

    post payments_webhook_events_path(provider: "fake"), params: body, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => webhook_signature(body)
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(Payments::Domain::Entities::PaymentWebhookEvent.count).to eq(0)
  end

  it "rejects unknown providers" do
    payment = build_payment
    body = webhook_body(payment_id: payment.id, provider_reference: payment.provider_reference)

    post payments_webhook_events_path(provider: "unknown"), params: body, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => webhook_signature(body)
    }

    expect(response).to have_http_status(:not_found)
    expect(Payments::Domain::Entities::PaymentWebhookEvent.count).to eq(0)
  end
end
