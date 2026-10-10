require "rails_helper"

RSpec.describe Billing::Adapters::Persistence::Invoice::Repository do
  it "saves and finds invoices" do
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

    invoice = Billing::Application::Commands::IssueInvoice.call(payment: payment).data.fetch(:invoice)
    repository = described_class.new

    expect(repository.find_by_number(invoice.number).number).to eq(invoice.number)
    expect(repository.find_by_id(invoice.id).number).to eq(invoice.number)
  end
end
