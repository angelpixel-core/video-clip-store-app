require "rails_helper"

RSpec.describe Payments::Adapters::Outbound::Webhooks::WebhookSimulator do
  let(:webhook_url) { "http://example.com/payments/webhooks/fake/events" }

  it "returns a failure when the webhook url is missing" do
    result = described_class.(
      webhook_url: "",
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: 1,
      provider_reference: "fake-abc123",
      amount_cents: 50_000
    )

    expect(result).to be_failure
    expect(result.code).to eq(:missing_webhook_url)
  end

  it "posts a signed payload and returns success on a 202 response" do
    response = instance_double(Net::HTTPResponse, code: "202", body: "accepted")
    http = instance_double(Net::HTTP)
    request = nil

    allow(Net::HTTP::Post).to receive(:new).and_wrap_original do |original, uri|
      request = original.call(uri)
    end

    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(response)

    result = described_class.(
      webhook_url: webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: 1,
      provider_reference: "fake-abc123",
      amount_cents: 50_000
    )

    expect(result).to be_success
    expect(result.data[:status_code]).to eq(202)
    expect(result.data[:body]).to eq("accepted")
    expect(result.data[:request_payload]).to include(
      id: "evt_123",
      type: "payment.succeeded",
      data: hash_including(provider_reference: "fake-abc123")
    )
    expect(request["X-Payment-Signature"]).to be_present
    expect(request["Content-Type"]).to eq("application/json")
  end

  it "includes the always-fail flag in the payload when requested" do
    response = instance_double(Net::HTTPResponse, code: "202", body: "accepted")
    http = instance_double(Net::HTTP)

    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(response)

    result = described_class.(
      webhook_url: webhook_url,
      provider: "fake",
      event_id: "evt_456",
      type: "payment.succeeded",
      payment_id: 1,
      provider_reference: "fake-abc123",
      amount_cents: 50_000,
      demo_fail_always: true
    )

    expect(result).to be_success
    expect(result.data[:request_payload]).to include(
      id: "evt_456",
      data: hash_including(demo_fail_always: true)
    )
  end

  it "returns a failure on a non-success response" do
    response = instance_double(Net::HTTPResponse, code: "403", body: "forbidden")
    http = instance_double(Net::HTTP)

    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(response)

    result = described_class.(
      webhook_url: webhook_url,
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: 1,
      provider_reference: "fake-abc123",
      amount_cents: 50_000
    )

    expect(result).to be_failure
    expect(result.code).to eq(:webhook_delivery_failed)
    expect(result.data[:response][:status_code]).to eq(403)
  end
end
