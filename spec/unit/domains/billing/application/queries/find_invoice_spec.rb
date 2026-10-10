require "rails_helper"

require Rails.root.join("app/domains/billing/application/queries/find_invoice")

RSpec.describe Billing::Application::Queries::FindInvoice do
  it "finds an invoice by number" do
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

    result = described_class.call(invoice_number: invoice.number)

    expect(result).to be_success
    expect(result.data.fetch(:invoice).number).to eq(invoice.number)
  end
end
