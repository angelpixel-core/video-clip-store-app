require "rails_helper"

RSpec.describe Notification do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "requires a project, pm, kind, and body" do
    notification = described_class.new

    expect(notification).not_to be_valid
    expect(notification.errors[:project]).to be_present
    expect(notification.errors[:account]).to be_present
    expect(notification.errors[:kind]).to be_present
    expect(notification.errors[:body]).to be_present
  end

  it "uses the account recipient API" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    with_pm_account = described_class.new(project: project, account: pm, kind: "project_created", body: "Project created")
    expect(with_pm_account).to be_valid
    expect(with_pm_account.recipient).to eq(pm)

    with_client_account = described_class.new(project: project, account: client, kind: "project_status_changed", body: "Order updated")
    expect(with_client_account).to be_valid
    expect(with_client_account.recipient).to eq(client)
  end

  it "defaults to unread and can be marked as read" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = described_class.create!(project: project, account: pm, kind: "project_created", body: "Project created")

    expect(described_class.unread).to include(notification)
    expect(described_class.read).not_to include(notification)

    notification.mark_as_read!

    expect(notification.read_at).to be_present
    expect(described_class.read).to include(notification)
    expect(described_class.unread).not_to include(notification)
  end

  it "broadcasts refreshes to the recipient stream" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(ActionCable.server).to receive(:broadcast).with(
      "client_notifications",
      hash_including(type: "notifications_updated", order_id: project.id, kind: "project_status_changed")
    )
    described_class.create!(project: project, account: client, kind: "project_status_changed", body: "Order updated")
  end
end
