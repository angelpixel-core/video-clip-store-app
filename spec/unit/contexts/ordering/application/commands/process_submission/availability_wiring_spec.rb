require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "stops before reserving when the availability policy rejects a line item" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_order(project, fulfillment_account: pm)
    payment_command = instance_double("PaymentCommand")
    availability_policy = instance_double("AvailabilityPolicy")
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    unavailable = Catalog::Domain::ValueObjects::Availability.new(available: false, reason: :marketplace_closed)

    expect(availability_policy).to receive(:evaluate).with(video_type, quantity: 1, context: { order_id: project.id }).and_return(unavailable)
    expect(payment_command).not_to receive(:call)
    expect(reserve_command).not_to receive(:call)
    expect(commit_command).not_to receive(:call)
    expect(release_command).not_to receive(:call)

    result = described_class.call(
      submission: submission,
      payment_command: payment_command,
      availability_policy: availability_policy,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command
    )

    expect(result).to be_failure
    expect(result.code).to eq(:unavailable)
    expect(result.data.fetch(:availability)).to eq(unavailable)
  end
end
