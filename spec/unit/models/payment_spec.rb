require "rails_helper"

RSpec.describe Payments::Domain::Aggregates::Payment do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a project and keeps historical payments while only one is active" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    historical = described_class.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: "payment-history-1",
      amount_cents: 10_000,
      currency: "usd"
    )

    active = described_class.create!(
      project: project,
      status: :pending,
      provider: "fake",
      idempotency_key: "payment-active-1",
      amount_cents: 15_000,
      currency: "usd"
    )

    expect(historical.project).to eq(project)
    expect(active).to be_active
    expect(project.active_payment).to eq(active)

    duplicate_active = described_class.new(
      project: project,
      status: :processing,
      provider: "fake",
      idempotency_key: "payment-active-2",
      amount_cents: 15_000,
      currency: "usd"
    )

    expect(duplicate_active).not_to be_valid
    expect(duplicate_active.errors[:base]).to include("Order already has an active payment")
  end

  it "rejects duplicate idempotency keys" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    described_class.create!(
      project: project,
      status: :pending,
      provider: "fake",
      idempotency_key: "same-key",
      amount_cents: 20_000,
      currency: "usd"
    )

    duplicate = described_class.new(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: "same-key",
      amount_cents: 20_000,
      currency: "usd"
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:idempotency_key]).to be_present
  end

  it "enqueues invoice generation after a payment succeeds" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)
    payment = described_class.create!(
      project: project,
      status: :processing,
      provider: "fake",
      idempotency_key: "invoice-job-1",
      amount_cents: 20_000,
      currency: "usd"
    )

    expect(Billing::Application::Handlers::GenerateInvoiceJob).to receive(:perform_later).with(payment.id)

    payment.update!(status: :succeeded, confirmed_at: Time.current)
  end
end
