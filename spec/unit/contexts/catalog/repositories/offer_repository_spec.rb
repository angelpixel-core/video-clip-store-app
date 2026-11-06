require "rails_helper"

RSpec.describe Catalog::Domain::Repositories::OfferRepository do
  it "returns offer variants from the new catalog tables" do
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    variant = OfferVariant.create!(offer:, offer_item_type: item_type, key: "highlight_reel", name: "Highlight Reel", description: "Polished highlight package", price_cents: 25_000, output_format: "mp4")

    expect(described_class.find_variant_by_id(variant.id)).to eq(variant)
    expect(described_class.all_variants).to contain_exactly(variant)
    expect(described_class.find_offer_by_key("video_editing")).to eq(offer)
  end
end
