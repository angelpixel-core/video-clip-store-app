require "rails_helper"

RSpec.describe Project do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(Order)
  end

  it "belongs to an owner and participant and starts as draft" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, status: :draft)

    expect(project.status).to eq("draft")
    expect(project.owner).to eq(client)
    expect(project.participant).to eq(pm)
  end

  it "keeps account ids populated when using the neutral associations" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")

    project = described_class.create!(owner: client, participant: pm, status: :draft)

    expect(project.owner_account_id).to eq(client.id)
    expect(project.participant_account_id).to eq(pm.id)
  end

  it "requires submission fields once submitted" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.new(owner: client, participant: pm, status: :draft)

    expect(project).to be_valid

    project.status = :pending

    expect(project).not_to be_valid
    expect(project.errors[:name]).to be_present
    expect(project.errors[:raw_footage_url]).to be_present
  end

  it "derives raw footage metadata for recognized urls" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, status: :draft, raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    expect(project.raw_footage_metadata_hash).to include(
      "provider" => "youtube",
      "video_id" => "dQw4w9WgXcQ"
    )
    expect(project.raw_footage_previewable?).to be(true)
  end

  it "derives vimeo metadata when the url is recognized" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, status: :draft, raw_footage_url: "https://vimeo.com/123456789")

    expect(project.raw_footage_metadata_hash).to include(
      "provider" => "vimeo",
      "video_id" => "123456789"
    )
  end

  it "moves through the project lifecycle" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    project.submit!
    expect(project.status).to eq("pending")

    project.accept!
    expect(project.status).to eq("in_progress")

    project.complete!
    expect(project.status).to eq("completed")
  end

  it "sums the project budget from selections" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    highlight_reel = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    social_cut = VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")

    project.video_type_selections.create!(video_type: highlight_reel, quantity: 2)
    project.video_type_selections.create!(video_type: social_cut, quantity: 1)

    expect(project.total_budget_cents).to eq(65_000)
  end

  it "rejects invalid lifecycle jumps" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    expect { project.accept! }.to raise_error(AASM::InvalidTransition)
  end

  it "exposes the latest payment state and refund request flags" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)

    expect(project.payment_status_for_listing).to eq("processing")
    expect(project.payment_badge_text).to eq("Pago en proceso")
    expect(project.can_accept_order?).to be(false)

    payment.update!(status: :succeeded)

    expect(project.reload.payment_status_for_listing).to eq("succeeded")
    expect(project.payment_badge_text).to eq("Pagado")
    expect(project.can_accept_order?).to be(true)

    payment.refunds.create!(payment_method_reference: payment.payment_method_reference, provider: payment.provider, provider_reference: "refund-123", status: :pending, amount_cents: payment.amount_cents)

    expect(project.reload.refund_request_pending?).to be(true)
    expect(project.can_accept_order?).to be(false)
    expect(project.payment_badge_text).to eq("Solicitud de reembolso")
  end
end
