require "rails_helper"

RSpec.describe Catalog::OfferCatalogPresenter do
  it "groups variants by offer and sorts them" do
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    first = OfferVariant.create!(offer:, offer_item_type: item_type, key: "social_cut", name: "Social Cut", description: "Short-form edit", price_cents: 15_000, output_format: "mp4", position: 2)
    second = OfferVariant.create!(offer:, offer_item_type: item_type, key: "highlight_reel", name: "Highlight Reel", description: "Polished highlight package", price_cents: 25_000, output_format: "mp4", position: 1)

    presenter = described_class.new(variants: [ first, second ])

    expect(presenter.count).to eq(2)
    expect(presenter.groups.size).to eq(1)
    expect(presenter.groups.first.offer).to eq(offer)
    expect(presenter.groups.first.variants).to eq([ second, first ])
  end
end
