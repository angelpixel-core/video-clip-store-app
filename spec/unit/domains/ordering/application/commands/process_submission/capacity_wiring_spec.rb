require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "stops when capacity reservation cannot be created" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_order(project, fulfillment_account: pm)
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    payment_command = instance_double("PaymentCommand")
    reserve_result = Core::Result::Failure.(message: "Capacity reservation already exists", code: :reservation_conflict, data: { order_id: project.id })

    expect(reserve_command).to receive(:call).with(order_id: project.id, units: 1).and_return(reserve_result)
    expect(payment_command).not_to receive(:call)
    expect(commit_command).not_to receive(:call)
    expect(release_command).not_to receive(:call)

    result = described_class.call(
      submission: submission,
      payment_command: payment_command,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command
    )

    expect(result).to be_failure
    expect(result.code).to eq(:reservation_conflict)
  end
end
