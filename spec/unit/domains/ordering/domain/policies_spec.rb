require "rails_helper"

RSpec.describe "Ordering policies" do
  let(:customer_snapshot) { Ordering::Domain::Entities::CustomerSnapshot.new(account_id: 1, name: "Client", email: "client@example.com", role: "client") }
  let(:offering_snapshot) { Ordering::Domain::Entities::OfferingSnapshot.new(offering_id: 7, name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4") }

  it "authorizes placement only for a draft with content" do
    draft = Ordering::Domain::Aggregates::Order.new(customer_snapshot: customer_snapshot)
    draft.add_line(offering_snapshot: offering_snapshot, quantity: 1)

    expect(Ordering::Domain::Policies::OrderPlacementPolicy.allowed?(draft)).to be(true)
  end

  it "blocks completion until the order is confirmed and delivered" do
    order = Ordering::Domain::Aggregates::Order.new(customer_snapshot: customer_snapshot)
    order.add_line(offering_snapshot: offering_snapshot, quantity: 1)
    order.place!
    order.confirm!

    expect(Ordering::Domain::Policies::OrderCompletionPolicy.allowed?(order)).to be(false)

    order.mark_delivery_ready!
    order.mark_delivered!

    expect(Ordering::Domain::Policies::OrderCompletionPolicy.allowed?(order)).to be(true)
  end

  it "blocks cancellation only after completion" do
    order = Ordering::Domain::Aggregates::Order.new(customer_snapshot: customer_snapshot)
    order.add_line(offering_snapshot: offering_snapshot, quantity: 1)

    expect(Ordering::Domain::Policies::OrderCancellationPolicy.allowed?(order)).to be(false)
    order.place!

    expect(Ordering::Domain::Policies::OrderCancellationPolicy.allowed?(order)).to be(true)
    order.confirm!
    order.mark_delivery_ready!
    order.mark_delivered!
    order.complete!

    expect(Ordering::Domain::Policies::OrderCancellationPolicy.allowed?(order)).to be(false)
  end

  it "authorizes acceptance only for a placed and paid order" do
    order = Ordering::Domain::Aggregates::Order.new(customer_snapshot: customer_snapshot)
    order.add_line(offering_snapshot: offering_snapshot, quantity: 1)

    expect(Ordering::Domain::Policies::OrderAcceptancePolicy.allowed?(order)).to be(false)

    order.place!
    expect(Ordering::Domain::Policies::OrderAcceptancePolicy.allowed?(order)).to be(false)

    order.mark_payment_paid!
    expect(Ordering::Domain::Policies::OrderAcceptancePolicy.allowed?(order)).to be(true)
  end
end
