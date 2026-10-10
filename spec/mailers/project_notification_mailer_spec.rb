require "rails_helper"

RSpec.describe ProjectNotificationMailer do
  describe "project_created" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_created(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your order Project was created")
      expect(mail.body.encoded).to include("Your order was created")
      expect(mail.body.encoded).to include("Order: Project")
      expect(mail.body.encoded).to include("Status: Pending")
    end

    it "sends a compact text email to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_created(project, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("New order created: Project")
      expect(mail.body.encoded).to include("New order created")
      expect(mail.body.encoded).to include("Order: Project")
      expect(mail.body.encoded).to include("Client: Client")
      expect(mail.body.encoded).to include("Status: In progress")
      expect(mail.body.encoded).to include("Budget:")
    end
  end

  describe "project_accepted" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_accepted(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your order Project was accepted")
      expect(mail.body.encoded).to include("Your order was accepted")
      expect(mail.body.encoded).to include("Next step: Your PM has accepted the order and work is in progress.")
    end

    it "sends a compact text email to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_accepted(project, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Order accepted: Project")
      expect(mail.body.encoded).to include("Order accepted")
      expect(mail.body.encoded).to include("The client has been notified")
    end
  end

  describe "project_rejected" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_rejected(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your order Project needs attention")
      expect(mail.body.encoded).to include("Your order needs attention")
      expect(mail.body.encoded).to include("Next step: Your PM needs changes")
    end

    it "sends a compact text email to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_rejected(project, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Order rejected: Project")
      expect(mail.body.encoded).to include("Order rejected")
      expect(mail.body.encoded).to include("The client should be notified")
    end
  end

  describe "project_cancelled" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_cancelled(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your order Project was cancelled")
      expect(mail.body.encoded).to include("Your order was cancelled")
    end
  end

  describe "project_refund_requested" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_refund_requested(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("A refund was requested for your order Project")
      expect(mail.body.encoded).to include("A refund was requested for your order")
      expect(mail.body.encoded).to include("operator review")
    end
  end

  describe "project_refund_approved" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_refund_approved(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your refund request for Project was approved")
      expect(mail.body.encoded).to include("refund was approved")
    end
  end

  describe "project_refund_rejected" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_refund_rejected(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your refund request for Project was rejected")
      expect(mail.body.encoded).to include("refund request was rejected")
    end
  end
end
