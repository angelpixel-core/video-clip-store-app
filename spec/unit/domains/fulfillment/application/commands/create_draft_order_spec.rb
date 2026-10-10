require "rails_helper"

require Rails.root.join("app/domains/fulfillment/application/commands/create_draft_order")

RSpec.describe Fulfillment::Application::Commands::CreateDraftOrder do
  it "returns the existing draft order for the client workspace" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    draft = Project.create!(owner: client, participant: pm, status: :draft)
    repository = instance_double("Repository")

    allow(repository).to receive(:find_or_create_draft_for_owner).with(client, pm).and_return(draft)

    result = described_class.call(client_workspace: client, pm_workspace: pm, repository: repository)

    expect(result).to be_success
    expect(result.data.fetch(:order)).to eq(draft)
    expect(Project.where(status: :draft).count).to eq(1)
  end

  it "creates a draft order when none exists" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    draft = instance_double(Project, persisted?: true, status: "draft", owner: client, participant: pm)
    repository = instance_double("Repository")

    allow(repository).to receive(:find_or_create_draft_for_owner).with(client, pm).and_return(draft)

    result = described_class.call(client_workspace: client, pm_workspace: pm, repository: repository)

    expect(result).to be_success
    expect(result.data.fetch(:order)).to eq(draft)
  end
end
