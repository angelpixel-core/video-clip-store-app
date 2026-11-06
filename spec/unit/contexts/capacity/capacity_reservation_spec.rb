require "rails_helper"

RSpec.describe Capacity::Domain::Entities::CapacityReservation do
  it "starts reserved and exposes reservation metadata" do
    now = Time.current

    reservation = described_class.reserve(order_id: 123, units: 2, expires_at: now + 1.hour, at: now)

    expect(reservation.order_id).to eq(123)
    expect(reservation.units).to eq(2)
    expect(reservation).to be_reserved
    expect(reservation).not_to be_committed
    expect(reservation).not_to be_released
    expect(reservation).not_to be_expired
    expect(reservation).not_to be_terminal
    expect(reservation.expires_at).to eq(now + 1.hour)
    expect(reservation.created_at).to eq(now)
    expect(reservation.updated_at).to eq(now)
  end

  it "commits, releases, and expires only from the reserved state" do
    reservation = described_class.reserve(order_id: 123, units: 1)
    committed_at = Time.current

    reservation.commit!(at: committed_at)

    expect(reservation).to be_committed
    expect(reservation).to be_terminal
    expect(reservation.committed_at).to eq(committed_at)
    expect(reservation.updated_at).to eq(committed_at)

    expect { reservation.release! }.to raise_error(Capacity::Domain::Errors::InvalidReservationTransition)
  end

  it "can be released from the reserved state" do
    reservation = described_class.reserve(order_id: 123, units: 1)
    released_at = Time.current

    reservation.release!(at: released_at)

    expect(reservation).to be_released
    expect(reservation).to be_terminal
    expect(reservation.released_at).to eq(released_at)
    expect(reservation.updated_at).to eq(released_at)
  end

  it "can be expired from the reserved state" do
    reservation = described_class.reserve(order_id: 123, units: 1)
    expired_at = Time.current

    reservation.expire!(at: expired_at)

    expect(reservation).to be_expired
    expect(reservation).to be_terminal
    expect(reservation.expired_at).to eq(expired_at)
    expect(reservation.updated_at).to eq(expired_at)
  end

  it "rejects invalid units and invalid initial status" do
    expect do
      described_class.reserve(order_id: 123, units: 0)
    end.to raise_error(ArgumentError, "Capacity reservation units must be positive")

    expect do
      described_class.new(order_id: 123, units: 1, status: :unknown)
    end.to raise_error(Capacity::Domain::Errors::InvalidReservationTransition, /Invalid reservation status/)

    expect do
      described_class.reserve(order_id: 0, units: 1)
    end.to raise_error(ArgumentError, "Capacity reservation order_id must be positive")
  end
end
