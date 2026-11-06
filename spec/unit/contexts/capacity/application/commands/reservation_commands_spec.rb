require "rails_helper"

RSpec.describe "Capacity reservation commands" do
  let(:repository) { instance_double(Capacity::Adapters::Persistence::CapacityReservation::Repository) }

  it "reserves capacity through the repository" do
    allow(repository).to receive(:find_by_order_id).with(123).and_return(nil)
    allow(repository).to receive(:save)

    result = Capacity::Application::Commands::ReserveCapacity.call(order_id: 123, units: 2, expires_at: Time.current + 1.hour, repository: repository)

    expect(result).to be_success
    expect(result.data[:reservation]).to be_reserved
    expect(result.data[:reservation].order_id).to eq(123)
    expect(result.data[:reservation].units).to eq(2)
    expect(repository).to have_received(:save)
  end

  it "returns the existing reservation when the same reservation already exists" do
    existing = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 123, units: 2)
    allow(repository).to receive(:find_by_order_id).with(123).and_return(existing)

    result = Capacity::Application::Commands::ReserveCapacity.call(order_id: 123, units: 2, repository: repository)

    expect(result).to be_success
    expect(result.data[:reservation]).to eq(existing)
  end

  it "commits, releases, and expires reservations through the repository" do
    reserved = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 123, units: 2, expires_at: Time.current - 1.minute)
    allow(repository).to receive(:find_by_order_id).with(123).and_return(reserved)
    allow(repository).to receive(:save)

    commit_result = Capacity::Application::Commands::CommitCapacity.call(order_id: 123, repository: repository)
    expect(commit_result).to be_success
    expect(commit_result.data[:reservation]).to be_committed

    expired = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 456, units: 1, expires_at: Time.current - 1.minute)
    allow(repository).to receive(:find_by_order_id).with(456).and_return(expired)

    expire_result = Capacity::Application::Commands::ExpireCapacityReservation.call(order_id: 456, repository: repository)
    expect(expire_result).to be_success
    expect(expire_result.data[:reservation]).to be_expired

    allow(repository).to receive(:find_by_order_id).with(789).and_return(Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 789, units: 1))

    release_result = Capacity::Application::Commands::ReleaseCapacity.call(order_id: 789, repository: repository)
    expect(release_result).to be_success
    expect(release_result.data[:reservation]).to be_released
  end

  it "returns a failure when a reservation is missing" do
    allow(repository).to receive(:find_by_order_id).with(999).and_return(nil)

    result = Capacity::Application::Commands::CommitCapacity.call(order_id: 999, repository: repository)

    expect(result).to be_failure
    expect(result.code).to eq(:reservation_not_found)
  end

  it "returns a failure when a reservation is not expired yet" do
    future = Capacity::Domain::Entities::CapacityReservation.reserve(order_id: 321, units: 1, expires_at: Time.current + 1.hour)
    allow(repository).to receive(:find_by_order_id).with(321).and_return(future)

    result = Capacity::Application::Commands::ExpireCapacityReservation.call(order_id: 321, repository: repository)

    expect(result).to be_failure
    expect(result.code).to eq(:reservation_not_expired)
  end
end
