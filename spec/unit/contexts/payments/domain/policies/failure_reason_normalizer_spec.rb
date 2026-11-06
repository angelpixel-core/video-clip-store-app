require "rails_helper"

RSpec.describe Payments::Domain::Policies::FailureReasonNormalizer do
  it "prefers an explicit code from the event payload" do
    event = Payments::Domain::Entities::PaymentWebhookEvent.new(payload: { "failure_reason_code" => "provider_timeout" })

    result = described_class.call(error: StandardError.new("boom"), event: event)

    expect(result).to eq("provider_timeout")
  end

  it "maps known error classes to stable codes" do
    result = described_class.call(error: Payments::Domain::Errors::DemoTransientFailure.new("boom"))

    expect(result).to eq("demo_transient_failure")
  end

  it "falls back to unknown_error for unmapped failures" do
    result = described_class.call(error: StandardError.new("boom"))

    expect(result).to eq("unknown_error")
  end
end
