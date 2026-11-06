require "rails_helper"

RSpec.describe Capacity::Domain::Policies::CapacityCalculationPolicy do
  it "reserves capacity based on active orders and reservations" do
    offer = instance_double(VideoType)
    order_scope = instance_double(ActiveRecord::Relation)
    reservation_scope = instance_double(ActiveRecord::Relation)

    allow(ENV).to receive(:fetch).with("CAPACITY_TOTAL_UNITS", 100).and_return("3")
    allow(Ordering::Adapters::Persistence::Order::OrderRecord).to receive(:where).with(status: %w[placed confirmed]).and_return(order_scope)
    allow(order_scope).to receive(:joins).with(:order_line_records).and_return(order_scope)
    allow(order_scope).to receive(:sum).with("order_lines.quantity").and_return(1)
    allow(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord).to receive(:where).with(status: "reserved").and_return(reservation_scope)
    allow(reservation_scope).to receive(:sum).with(:units).and_return(1)

    expect(described_class.available_units_for(offer)).to eq(1)
  end

  it "never returns a negative availability" do
    offer = instance_double(VideoType)
    order_scope = instance_double(ActiveRecord::Relation)
    reservation_scope = instance_double(ActiveRecord::Relation)

    allow(ENV).to receive(:fetch).with("CAPACITY_TOTAL_UNITS", 100).and_return("1")
    allow(Ordering::Adapters::Persistence::Order::OrderRecord).to receive(:where).with(status: %w[placed confirmed]).and_return(order_scope)
    allow(order_scope).to receive(:joins).with(:order_line_records).and_return(order_scope)
    allow(order_scope).to receive(:sum).with("order_lines.quantity").and_return(1)
    allow(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord).to receive(:where).with(status: "reserved").and_return(reservation_scope)
    allow(reservation_scope).to receive(:sum).with(:units).and_return(2)

    expect(described_class.available_units_for(offer)).to eq(0)
  end
end
