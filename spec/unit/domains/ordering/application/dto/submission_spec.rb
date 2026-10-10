require "rails_helper"

RSpec.describe Ordering::Application::DTO::Submission do
  it "derives order data from a project bridge" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 2)

    submission = described_class.from_order(project, fulfillment_account: pm)

    expect(submission.order).to eq(project)
    expect(submission.fulfillment_account).to eq(pm)
    expect(submission.customer_snapshot.name).to eq("Client")
    expect(submission.line_items.count).to eq(1)
    expect(submission.total_cents).to eq(50_000)
  end

  it "requires an order and fulfillment account" do
    expect do
      described_class.new(order: nil, fulfillment_account: nil)
    end.to raise_error(ArgumentError, /order is required/)
  end
end
