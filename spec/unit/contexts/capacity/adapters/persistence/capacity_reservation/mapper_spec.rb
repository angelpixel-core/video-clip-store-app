require "rails_helper"

RSpec.describe Capacity::Adapters::Persistence::CapacityReservation::Mapper do
  it "maps a record to a domain reservation" do
    now = Time.current
    record = Struct.new(:order_id, :units, :status, :expires_at, :committed_at, :released_at, :expired_at, :created_at, :updated_at).new(
      123,
      2,
      "reserved",
      now + 1.hour,
      nil,
      nil,
      nil,
      now,
      now
    )

    reservation = described_class.new.to_domain(record)

    expect(reservation.order_id).to eq(123)
    expect(reservation.units).to eq(2)
    expect(reservation).to be_reserved
    expect(reservation.expires_at).to eq(now + 1.hour)
  end

  it "writes a reservation back to a record" do
    reservation = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 123, units: 2, expires_at: Time.current + 1.hour)
    record = Struct.new(:order_id, :units, :status, :expires_at, :committed_at, :released_at, :expired_at).new

    described_class.new.write(reservation, record)

    expect(record.order_id).to eq(123)
    expect(record.units).to eq(2)
    expect(record.status).to eq("reserved")
    expect(record.expires_at).to be_present
  end
end
