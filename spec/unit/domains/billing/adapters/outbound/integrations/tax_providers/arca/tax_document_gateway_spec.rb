require "rails_helper"

require Rails.root.join("app/domains/billing/adapters/outbound/integrations/tax_providers/arca/tax_document_gateway")

RSpec.describe Billing::Adapters::Outbound::Integrations::TaxProviders::ARCA::TaxDocumentGateway do
  it "calculates tax for an AR invoice" do
    identity = Billing::Domain::ValueObjects::BillingIdentity.new(name: "Client", country_code: "AR")
    invoice = Billing::Domain::Aggregates::Invoice.new(
      number: "INV-000001",
      order_id: 1,
      order_name: "Project Draft",
      recipient_name: "Client",
      recipient_email: "client@example.com",
      lines: [ Billing::Domain::Entities::InvoiceLine.new(description: "Highlight Reel", quantity: 2, unit_amount_cents: 25_000) ],
      content: "<html></html>",
      billing_identity: identity
    )

    result = described_class.new.issue(invoice:)

    expect(result).to be_success
    expect(result.data.fetch(:provider)).to eq("ARCA")
    expect(result.data.fetch(:tax_amount_cents)).to eq(10_500)
  end
end
