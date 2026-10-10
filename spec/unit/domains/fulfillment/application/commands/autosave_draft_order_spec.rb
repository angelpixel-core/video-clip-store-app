require "rails_helper"

require Rails.root.join("app/domains/fulfillment/application/commands/autosave_draft_order")

RSpec.describe Fulfillment::Application::Commands::AutosaveDraftOrder do
  it "updates the draft order and syncs selections" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    order = Project.create!(owner: client, participant: pm, status: :draft)
    highlight_reel = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    social_cut = VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
    repository = Fulfillment::Adapters::Persistence::Order::Repository.new

    result = described_class.call(
      order: order,
      participant: pm,
      attributes: { name: "Project Beta", raw_footage_url: "https://example.com/beta.mov" },
      selections: [
        { video_type_id: highlight_reel.id, quantity: 2 },
        { video_type_id: social_cut.id, quantity: 1 }
      ],
      repository: repository
    )

    expect(result).to be_success
    expect(order.reload.status).to eq("draft")
    expect(order.name).to eq("Project Beta")
    expect(order.participant).to eq(pm)
    expect(order.video_type_selections.count).to eq(2)
  end

  it "returns a failure when the order is invalid" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    order = Project.create!(owner: client, participant: pm, status: :draft)
    repository = Fulfillment::Adapters::Persistence::Order::Repository.new

    allow(order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(order))

    result = described_class.call(
      order: order,
      participant: pm,
      attributes: { name: "Project Beta", raw_footage_url: "https://example.com/beta.mov" },
      selections: [],
      repository: repository
    )

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_record)
  end
end
