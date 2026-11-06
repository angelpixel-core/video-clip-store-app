require "rails_helper"

RSpec.describe Payments::Domain::Aggregates::Payment do
  it "is a pure Ruby POPO domain aggregate decoupled from ActiveRecord" do
    expect(described_class.superclass).to eq(Object)
    expect(described_class < ApplicationRecord).to be_falsey
  end

  it "encapsulates payment domain status and attributes" do
    payment = described_class.new(
      id: 1,
      project_id: 10,
      status: "succeeded",
      provider: "fake",
      idempotency_key: "idem-1",
      amount_cents: 25_000,
      currency: "USD"
    )

    expect(payment.id).to eq(1)
    expect(payment.project_id).to eq(10)
    expect(payment.amount_cents).to eq(25_000)
    expect(payment.currency).to eq("USD")
    expect(payment).to be_succeeded
    expect(payment.status_object).to be_a(Payments::Domain::ValueObjects::PaymentStatus)
    expect(payment.idempotency_key_object).to be_a(Payments::Domain::ValueObjects::IdempotencyKey)
  end
end
