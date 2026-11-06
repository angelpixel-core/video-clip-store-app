require "rails_helper"

RSpec.describe Billing::Adapters::Outbound::Mailers::InvoiceMailer do
  describe "invoice_ready" do
    it "sends the invoice email with an attachment link" do
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
        provider_reference: "inv-123",
        invoice_number: "INV-000001",
        invoice_generated_at: Time.current
      )
      payment.invoice_document.attach(io: StringIO.new("invoice html"), filename: "INV-000001.html", content_type: "text/html")
      intent = Payments::Domain::Entities::PaymentInvoiceDeliveryIntent.create!(payment: payment, status: :pending, scheduled_at: Time.current)

      mail = described_class.invoice_ready(intent)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your invoice for Project")
      expect(mail.body.encoded).to include("Your invoice is ready")
      expect(mail.body.encoded).to include("Invoice: INV-000001")
      expect(mail.attachments).not_to be_empty
    end
  end
end
