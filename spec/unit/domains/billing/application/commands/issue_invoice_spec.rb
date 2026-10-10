require "rails_helper"

require Rails.root.join("app/domains/billing/application/commands/issue_invoice")

RSpec.describe Billing::Application::Commands::IssueInvoice do
  it "persists an invoice in billing and returns it" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    order = Order.create!(owner: client, participant: pm, name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    order.video_type_selections.create!(video_type: video_type, quantity: 2)

    payment = Payments::Domain::Aggregates::Payment.create!(
      project: order,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "pay-123"
    )

    expect do
      @result = described_class.call(payment: payment)
    end.to change(Billing::Adapters::Persistence::Invoice::InvoiceRecord, :count).by(1)

    expect(@result).to be_success
    invoice = @result.data.fetch(:invoice)

    expect(invoice.number).to eq("INV-000000#{payment.id}")
    expect(invoice.tax_amount_cents).to eq(10_500)
    expect(invoice.status).to eq("issued")
    expect(invoice.billing_identity).to be_a(Billing::Domain::ValueObjects::BillingIdentity)
  end
end
