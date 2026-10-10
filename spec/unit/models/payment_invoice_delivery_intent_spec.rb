require "rails_helper"

RSpec.describe Payments::Domain::Entities::PaymentInvoiceDeliveryIntent do
  it "enqueues the dispatch job after commit when created" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 20_000,
      currency: "USD",
      provider_reference: "inv-123"
    )

    intent = described_class.create!(payment: payment, status: :pending, scheduled_at: Time.current)

    expect(Billing::Application::Handlers::DispatchInvoiceJob).to receive(:perform_later).with(intent.id)

    intent.send(:enqueue_dispatch_job)
  end
end
