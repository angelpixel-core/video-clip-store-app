require "rails_helper"

RSpec.describe Offering do
  it "inherits from the catalog offer model" do
    expect(described_class.superclass).to eq(Offer)
  end
end
