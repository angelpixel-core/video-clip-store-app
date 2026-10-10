require "rails_helper"

RSpec.describe AppContainer do
  it "registers the billing payment captured consumer" do
    expect(described_class["billing.event_consumers.payment_captured"]).to eq(Billing::Adapters::Inbound::EventConsumers::PaymentCapturedConsumer)
  end
end
