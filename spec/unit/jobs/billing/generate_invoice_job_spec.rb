require "rails_helper"

RSpec.describe Billing::Application::Handlers::GenerateInvoiceJob do
  it "attaches an invoice and creates a payment invoice delivery intent once" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 20_000,
      currency: "USD",
      provider_reference: "inv-123"
    )

    expect do
      described_class.perform_now(payment.id)
    end.to change(Payments::Domain::Entities::PaymentInvoiceDeliveryIntent, :count).by(1)

    payment.reload
    expect(payment.invoice_generated_at).to be_present
    expect(payment.invoice_number).to eq("INV-#{payment.id.to_s.rjust(7, '0')}")
    expect(payment.invoice_document).to be_attached
    expect(payment.invoice_document.filename.to_s).to eq("INV-#{payment.id.to_s.rjust(7, '0')}.html")
  end
end
