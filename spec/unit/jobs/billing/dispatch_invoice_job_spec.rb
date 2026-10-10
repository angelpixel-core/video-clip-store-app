require "rails_helper"

RSpec.describe Billing::Application::Handlers::DispatchInvoiceJob do
  it "delivers the invoice email and marks the intent sent" do
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
    payment.invoice_document.attach(io: StringIO.new("invoice html"), filename: "INV-000001.html", content_type: "text/html")
    intent = Payments::Domain::Entities::PaymentInvoiceDeliveryIntent.create!(payment: payment, status: :pending, scheduled_at: Time.current)

    mail = instance_double(ActionMailer::MessageDelivery)
    expect(Billing::Adapters::Outbound::Mailers::InvoiceMailer).to receive(:invoice_ready).with(intent).and_return(mail)
    expect(mail).to receive(:deliver_now)

    described_class.perform_now(intent.id)

    expect(intent.reload.sent?).to eq(true)
    expect(intent.processed_at).to be_present
    expect(payment.reload.invoice_emailed_at).to be_present
  end
end
