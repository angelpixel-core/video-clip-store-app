require "rails_helper"

RSpec.describe "Ordering events" do
  it "builds the event inheritance chain" do
    expect(Ordering::Domain::Events::OrderEvent.superclass).to eq(::Domain::Events::DomainEvent)
    expect(Ordering::Domain::Events::OrderDraftedEvent.superclass).to eq(Ordering::Domain::Events::OrderEvent)
    expect(Ordering::Domain::Events::OrderPlacedEvent.superclass).to eq(Ordering::Domain::Events::OrderEvent)
    expect(Ordering::Domain::Events::OrderConfirmedEvent.superclass).to eq(Ordering::Domain::Events::OrderEvent)
    expect(Ordering::Domain::Events::OrderCancelledEvent.superclass).to eq(Ordering::Domain::Events::OrderEvent)
    expect(Ordering::Domain::Events::OrderCompletedEvent.superclass).to eq(Ordering::Domain::Events::OrderEvent)
    expect(Ordering::Domain::Events::OrderPaymentFailedEvent.superclass).to eq(Ordering::Domain::Events::OrderEvent)
  end

  it "carries order identity and payload" do
    order = Ordering::Domain::Aggregates::Order.new
    event = Ordering::Domain::Events::OrderPlacedEvent.new(order: order, payload: { kind: "placed" })

    expect(event.aggregate_id).to eq(order.id)
    expect(event.aggregate_uid).to eq(order.uid&.to_s)
    expect(event.payload).to include(kind: "placed")
  end
end
