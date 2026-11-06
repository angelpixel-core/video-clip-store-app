require "rails_helper"

RSpec.describe Capacity::Adapters::Persistence::CapacityReservation::Repository do
  let(:mapper) { instance_double(Capacity::Adapters::Persistence::CapacityReservation::Mapper) }
  let(:repository) { described_class.new(mapper:) }

  it "inherits from the capacity reservation contract" do
    expect(described_class.superclass).to eq(Capacity::Domain::Repositories::CapacityReservation::Contract)
  end

  it "finds a reservation by order id" do
    record = instance_double(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord)
    reservation = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 123, units: 2)

    expect(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord).to receive(:find_by).with(order_id: 123).and_return(record)
    expect(mapper).to receive(:to_domain).with(record).and_return(reservation)

    expect(repository.find_by_order_id(123)).to eq(reservation)
  end

  it "saves a reservation through the record" do
    reservation = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 123, units: 2)
    record = instance_double(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord, save!: true)

    expect(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord).to receive(:find_or_initialize_by).with(order_id: 123).and_return(record)
    expect(mapper).to receive(:write).with(reservation, record).and_return(record)
    expect(record).to receive(:save!)

    expect(repository.save(reservation)).to eq(reservation)
  end

  it "deletes the reservation record when present" do
    reservation = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 123, units: 2)
    record = instance_double(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord)

    expect(Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord).to receive(:find_by).with(order_id: 123).and_return(record)
    expect(record).to receive(:destroy!)

    repository.delete(reservation)
  end
end
