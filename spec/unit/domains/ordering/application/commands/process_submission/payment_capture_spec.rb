require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "processes a submission and creates payment via the payment command" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 2)

    submission = Ordering::Application::DTO::Submission.from_order(project_bridge, fulfillment_account: pm)
    payment_gateway = instance_double("PaymentGateway")
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 123, active?: true)
    payment_result = Core::Result::Success.(data: { payment: payment })
    reservation = instance_double("CapacityReservation", order_id: project_bridge.id)
    reserve_result = Core::Result::Success.(data: { reservation: reservation })
    commit_result = Core::Result::Success.(data: { reservation: reservation })
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    payment_command = instance_double("PaymentCommand")

    expect(reserve_command).to receive(:call).with(order_id: project_bridge.id, units: 2).and_return(reserve_result)
    expect(payment_command).to receive(:call).with(order: project_bridge, provider: "fake", payment_method_type: "card", gateway: payment_gateway).and_return(payment_result)
    expect(commit_command).to receive(:call).with(order_id: project_bridge.id).and_return(commit_result)
    expect(release_command).not_to receive(:call)

    result = described_class.call(
      submission: submission,
      payment_command: payment_command,
      payment_gateway: payment_gateway,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command
    )

    expect(result).to be_success
    expect(result.data.fetch(:submission)).to eq(submission)
    expect(result.data.fetch(:order)).to eq(project_bridge)
    expect(result.data.fetch(:payment)).to eq(payment)
    expect(result.data.fetch(:reservation)).to eq(reservation)
  end

  it "returns the payment failure when the payment command fails" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 2)

    submission = Ordering::Application::DTO::Submission.from_order(project_bridge, fulfillment_account: pm)
    payment_result = Core::Result::Failure.(message: "gateway down", code: :provider_error, data: { provider: "fake" })
    reservation = instance_double("CapacityReservation", order_id: project_bridge.id)
    reserve_result = Core::Result::Success.(data: { reservation: reservation })
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    payment_command = instance_double("PaymentCommand")

    expect(reserve_command).to receive(:call).with(order_id: project_bridge.id, units: 2).and_return(reserve_result)
    expect(payment_command).to receive(:call).and_return(payment_result)
    expect(commit_command).not_to receive(:call)
    expect(release_command).to receive(:call).with(order_id: project_bridge.id)
    expect(Billing::Application::Handlers::GenerateInvoiceJob).not_to receive(:perform_later)
    expect(NotificationJob).not_to receive(:perform_later)

    result = described_class.call(
      submission: submission,
      payment_command: payment_command,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command
    )

    expect(result).to be_failure
    expect(result.message).to eq("gateway down")
    expect(result.code).to eq(:provider_error)
  end

  it "resolves an alternate provider through the gateway container" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_order(project_bridge, fulfillment_account: pm, payment_provider: "stripe")
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 999, active?: true)
    payment_result = Core::Result::Success.(data: { payment: payment })
    payment_gateway = Payments::Application::Gateways.resolve("stripe")
    reservation = instance_double("CapacityReservation", order_id: project_bridge.id)
    reserve_result = Core::Result::Success.(data: { reservation: reservation })
    commit_result = Core::Result::Success.(data: { reservation: reservation })
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    payment_command = instance_double("PaymentCommand")

    expect(reserve_command).to receive(:call).with(order_id: project_bridge.id, units: 1).and_return(reserve_result)
    expect(payment_command).to receive(:call).with(order: project_bridge, provider: "stripe", payment_method_type: "card", gateway: payment_gateway).and_return(payment_result)
    expect(commit_command).to receive(:call).with(order_id: project_bridge.id).and_return(commit_result)
    expect(release_command).not_to receive(:call)

    result = described_class.call(
      submission: submission,
      payment_gateway: payment_gateway,
      payment_command: payment_command,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command
    )

    expect(result).to be_success
  end
end
