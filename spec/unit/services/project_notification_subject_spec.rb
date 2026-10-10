require "rails_helper"

RSpec.describe ProjectNotificationSubject do
  it "builds the pm subject for accepted orders" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    subject = described_class.call(project: project, recipient_role: :pm, event_type: :project_accepted)

    expect(subject).to eq("Order accepted: Project")
  end

  it "builds the client subject for completed orders" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    subject = described_class.call(project: project, recipient_role: :client, event_type: :project_completed)

    expect(subject).to eq("Your order Project has been completed")
  end

  it "builds the client subject for refund requests" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    subject = described_class.call(project: project, recipient_role: :client, event_type: :project_refund_requested)

    expect(subject).to eq("A refund was requested for your order Project")
  end

  it "builds the client subject for cancellations" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    subject = described_class.call(project: project, recipient_role: :client, event_type: :project_cancelled)

    expect(subject).to eq("Your order Project was cancelled")
  end

  it "builds subjects for refund review outcomes" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    approved = described_class.call(project: project, recipient_role: :client, event_type: :project_refund_approved)
    rejected = described_class.call(project: project, recipient_role: :client, event_type: :project_refund_rejected)

    expect(approved).to eq("Your refund request for Project was approved")
    expect(rejected).to eq("Your refund request for Project was rejected")
  end

  it "builds the pm subject for reopened orders" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :cancelled)

    subject = described_class.call(project: project, recipient_role: :pm, event_type: :project_reopened)

    expect(subject).to eq("Order reopened: Project")
  end
end
