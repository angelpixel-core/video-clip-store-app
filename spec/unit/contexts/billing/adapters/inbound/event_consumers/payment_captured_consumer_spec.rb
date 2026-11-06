require "rails_helper"

RSpec.describe Billing::Adapters::Inbound::EventConsumers::PaymentCapturedConsumer do
  it "delegates invoice issuance to the billing command" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    order = Order.create!(owner: client, participant: pm, name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :pending)

    payment = Payments::Domain::Aggregates::Payment.create!(
      project: order,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "pay-123"
    )
    event = Payments::Domain::Events::PaymentCaptured.new(payment: payment)

    expect(Billing::Application::Commands::IssueInvoice).to receive(:call).with(payment: payment)

    described_class.call(event)
  end
end
