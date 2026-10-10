require "rails_helper"

RSpec.describe Ordering::Domain::Aggregates::Order do
  it "can exist as a draft without a source video" do
    order = described_class.new

    expect(order).to be_draft
    expect(order.source_video).to be_nil
  end

  it "records a drafted event through the draft factory" do
    customer = Ordering::Domain::Entities::CustomerSnapshot.new(account_id: 1, name: "Client", email: "client@example.com", role: "client")

    order = described_class.draft(customer_snapshot: customer)

    expect(order.domain_events.last).to be_a(Ordering::Domain::Events::OrderDraftedEvent)
  end

  it "assigns a public uid when given a relational id" do
    order = described_class.new

    order.assign_identity!(id: 42)

    expect(order.id).to eq(42)
    expect(order.uid.to_s).to match(/\Aord_42_[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
  end

  it "computes totals from order lines" do
    customer = Ordering::Domain::Entities::CustomerSnapshot.new(account_id: 1, name: "Client", email: "client@example.com", role: "client")
    offering = Ordering::Domain::Entities::OfferingSnapshot.new(offering_id: 7, name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    order = described_class.new(customer_snapshot: customer)
    order.add_line(offering_snapshot: offering, quantity: 2)

    expect(order.total_cents).to eq(50_000)
    expect(order.line_items.size).to eq(1)
    expect(order.order_lines.size).to eq(1)
  end

  it "supports the core lifecycle transitions" do
    customer = Ordering::Domain::Entities::CustomerSnapshot.new(account_id: 1, name: "Client", email: "client@example.com", role: "client")
    offering = Ordering::Domain::Entities::OfferingSnapshot.new(offering_id: 7, name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    order = described_class.new(customer_snapshot: customer)
    order.add_line(offering_snapshot: offering, quantity: 1)

    order.place!
    order.confirm!
    order.start_production!
    order.mark_delivery_ready!
    order.mark_delivered!
    order.complete!

    expect(order).to be_completed
    expect(order.delivery_status).to be_delivered
  end
end
