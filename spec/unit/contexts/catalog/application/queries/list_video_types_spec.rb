require "rails_helper"

RSpec.describe Catalog::Application::Queries::ListPublicVideoTypes do
  it "returns public variants from the new catalog schema" do
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    variant = OfferVariant.create!(offer:, offer_item_type: item_type, key: "highlight_reel", name: "Highlight Reel", description: "Polished highlight package", price_cents: 25_000, output_format: "mp4")

    allow(Catalog::Domain::Repositories::OfferRepository).to receive(:public_variants).and_return([ variant ])
    allow(Catalog::Domain::Policies::VisibilityPolicy).to receive(:visible_to?).and_return(true)

    result = described_class.call(account: instance_double("Account"))

    expect(result).to be_success
    expect(result.data.fetch(:video_types)).to contain_exactly(variant)
    expect(result.data.fetch(:video_types).first.offer).to eq(offer)
  end
end

RSpec.describe Catalog::Application::Queries::ListAdminVideoTypes do
  it "returns all variants from the new catalog schema" do
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    variant = OfferVariant.create!(offer:, offer_item_type: item_type, key: "social_cut", name: "Social Cut", description: "Short-form edit for social channels", price_cents: 15_000, output_format: "mp4")

    result = described_class.call

    expect(result).to be_success
    expect(result.data.fetch(:video_types)).to contain_exactly(variant)
  end
end

RSpec.describe Catalog::Application::Queries::FindVideoType do
  it "returns the matching variant dto from the new catalog schema" do
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    variant = OfferVariant.create!(offer:, offer_item_type: item_type, key: "social_cut", name: "Social Cut", description: "Short-form edit for social channels", price_cents: 15_000, output_format: "mp4")

    result = described_class.call(id: variant.id)

    expect(result).to be_success
    dto = result.data.fetch(:video_type)
    expect(dto.id).to eq(variant.id)
    expect(dto.name).to eq("Social Cut")
    expect(dto.price_cents).to eq(15_000)
  end
end
