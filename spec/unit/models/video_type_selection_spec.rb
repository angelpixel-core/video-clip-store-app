require "rails_helper"

RSpec.describe VideoTypeSelection do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a project and a video type" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov")
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 10_000, output_format: "mp4")
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    OfferVariant.create!(offer:, offer_item_type: item_type, key: "highlight_reel", name: video_type.name, description: video_type.description, price_cents: 12_500, output_format: video_type.output_format)

    selection = described_class.create!(project: project, video_type: video_type, quantity: 2)

    expect(selection.project).to eq(project)
    expect(selection.video_type).to eq(video_type)
    expect(selection.offer_variant_name).to eq("Highlight Reel")
    expect(selection.offer_variant_price_cents).to eq(12_500)
    expect(project.video_types).to contain_exactly(video_type)
  end
end
