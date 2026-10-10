require "rails_helper"

RSpec.describe Fulfillment::Application::Commands::SubmitOrder do
  it "submits a draft order, creates a payment, and enqueues notification dispatch" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    order = Project.create!(owner: client, participant: pm, name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    repository = Fulfillment::Adapters::Persistence::Order::Repository.new

    expect(NotificationJob).to receive(:perform_later).with(order.id)

    result = described_class.call(
      order: order,
      participant: pm,
      attributes: { name: "Project Draft", raw_footage_url: "https://example.com/draft.mov" },
      selections: [ { video_type_id: video_type.id, quantity: 2 } ],
      repository: repository
    )

    expect(result).to be_success
    expect(order.reload.status).to eq("pending")
    expect(order.active_payment).to be_present
    expect(order.active_payment.amount_cents).to eq(50_000)
    expect(order.video_type_selections.count).to eq(1)
  end

  it "returns a failure when there are no selections" do
    order = Project.create!(owner: workspace_account(:client, email: "client@example.com", name: "Client"), participant: workspace_account(:pm, email: "submission-failure-pm@example.com"), name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)
    repository = Fulfillment::Adapters::Persistence::Order::Repository.new

    result = described_class.call(
      order: order,
      participant: workspace_account(:pm, email: "pm@example.com", name: "PM"),
      attributes: { name: "Project Draft", raw_footage_url: "https://example.com/draft.mov" },
      selections: [],
      repository: repository
    )

    expect(result).to be_failure
    expect(result.message).to eq("Add at least one video type")
    expect(order.errors.full_messages).to include("Add at least one video type")
  end
end
