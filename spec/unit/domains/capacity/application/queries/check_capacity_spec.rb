require "rails_helper"

RSpec.describe Capacity::Application::Queries::CheckCapacity do
  it "returns availability from the capacity policy" do
    offer = instance_double(VideoType)

    allow(Capacity::Domain::Policies::CapacityCalculationPolicy).to receive(:available_units_for).with(offer).and_return(2)

    result = described_class.call(offer: offer, quantity: 3)

    expect(result).to be_success
    expect(result.data).to eq(available: false, available_units: 2)
  end

  it "marks the request available when the quantity fits" do
    offer = instance_double(VideoType)

    allow(Capacity::Domain::Policies::CapacityCalculationPolicy).to receive(:available_units_for).with(offer).and_return(2)

    result = described_class.call(offer: offer, quantity: 2)

    expect(result).to be_success
    expect(result.data).to eq(available: true, available_units: 2)
  end

  it "rejects zero quantity requests" do
    offer = instance_double(VideoType)

    allow(Capacity::Domain::Policies::CapacityCalculationPolicy).to receive(:available_units_for).with(offer).and_return(2)

    result = described_class.call(offer: offer, quantity: 0)

    expect(result).to be_success
    expect(result.data).to eq(available: false, available_units: 2)
  end
end
