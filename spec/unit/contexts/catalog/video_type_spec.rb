require "rails_helper"

RSpec.describe Catalog::Domain::Entities::VideoType do
  it "uses the catalog availability policy" do
    offer = described_class.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")

    allow(Catalog::Domain::Policies::AvailabilityPolicy).to receive(:available?).with(offer).and_return(true)

    expect(offer.available?).to be(true)
  end
end
