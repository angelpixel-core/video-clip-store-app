require "rails_helper"

RSpec.describe Orders::ActionService do
  it "accepts a pending order, marks unread pm notifications as read, and creates a client notification" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)
    unread_notification = Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_accepted).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_accepted).with(project, recipient_role: :pm).and_return(pm_mail)

    result = described_class.call(project: project, event: :accept)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(true)
    expect(project.reload.status).to eq("in_progress")
    expect(unread_notification.reload.read_at).to be_present
    expect(Notification.where(project: project, kind: "project_accepted")).to exist
  end

  it "cancels an unpaid pending order and creates a client notification" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_cancelled).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_cancelled).with(project, recipient_role: :pm).and_return(pm_mail)

    result = described_class.call(project: project, event: :cancel)

    expect(result).to be_success
    expect(project.reload.status).to eq("cancelled")
    expect(Notification.where(project: project, kind: "project_cancelled")).to exist
  end

  it "reopens a cancelled order back to draft and notifies the pm" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Cancelled", raw_footage_url: "https://example.com/cancelled.mov", status: :cancelled)

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_reopened).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_reopened).with(project, recipient_role: :pm).and_return(pm_mail)

    result = described_class.call(project: project, event: :reopen)

    expect(result).to be_success
    expect(project.reload.status).to eq("draft")
    expect(Notification.where(project: project, kind: "project_reopened")).to exist
  end

  it "completes an in-progress order and creates a client notification" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_completed).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_completed).with(project, recipient_role: :pm).and_return(pm_mail)

    result = described_class.call(project: project, event: :complete)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(false)
    expect(project.reload.status).to eq("completed")
    expect(Notification.where(project: project, kind: "project_completed")).to exist
  end

  it "creates a pending refund request for a paid order" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)
    allow(ProjectNotificationMailer).to receive(:project_refund_requested).and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))

    result = described_class.call(project: project, event: :request_refund)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(false)
    expect(project.reload.refund_request_pending?).to be(true)
    expect(payment.refunds.pending.count).to eq(1)
    expect(Notification.where(project: project, kind: "project_refund_requested")).to exist
  end

  it "approves a pending refund request" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)
    Payments::Application::Commands::RequestRefund.call(payment: payment, amount_cents: payment.amount_cents)

    result = described_class.call(project: project, event: :approve_refund_request)

    expect(result).to be_success
    expect(project.reload.refund_request_processing?).to be(true)
    expect(Notification.where(project: project, kind: "project_refund_processing")).to exist
  end

  it "rejects a pending refund request" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)
    Payments::Application::Commands::RequestRefund.call(payment: payment, amount_cents: payment.amount_cents)

    result = described_class.call(project: project, event: :reject_refund_request)

    expect(result).to be_success
    expect(project.reload.refund_request_failed?).to be(true)
    expect(Notification.where(project: project, kind: "project_refund_rejected")).to exist
  end

  it "returns a failure for stale actions" do
    project = Project.create!(owner: workspace_account(:client, email: "client@example.com", name: "Client"), participant: workspace_account(:pm, email: "pm@example.com", name: "PM"), name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)

    result = described_class.call(project: project, event: :complete)

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_transition)
  end
end
