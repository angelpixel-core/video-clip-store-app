require "rails_helper"

RSpec.describe OfferingVariant do
  it "inherits from the catalog offer variant model" do
    expect(described_class.superclass).to eq(OfferVariant)
  end
end
