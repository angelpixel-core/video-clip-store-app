require "rails_helper"

RSpec.describe Fulfillment::Adapters::Persistence::Order::Repository do
  describe "#find_for_show" do
    it "loads the show associations" do
      project = Project.create!(owner: workspace_account(:client), participant: workspace_account(:pm), name: "Show me", status: :draft)

      found = described_class.new.find_for_show(project.id)

      expect(found).to eq(project)
      expect(found.association(:owner)).to be_loaded
      expect(found.association(:participant)).to be_loaded
      expect(found.association(:comments)).to be_loaded
      expect(found.association(:video_type_selections)).to be_loaded
    end
  end

  describe "#find_for_edit" do
    it "loads the edit associations" do
      client = workspace_account(:client)
      project = Project.create!(owner: client, participant: workspace_account(:pm), name: "Edit me", status: :draft)

      found = described_class.new.find_for_edit(client, project.id)

      expect(found).to be_a(Order)
      expect(found.id).to eq(project.id)
      expect(found.association(:video_type_selections)).to be_loaded
    end
  end

  describe "#find_for_workspace_action" do
    it "scopes to the participant workspace" do
      client = workspace_account(:client)
      pm = workspace_account(:pm)
      project = Project.create!(owner: client, participant: pm, name: "Workspace action", status: :draft)

      found = described_class.new.find_for_workspace_action(pm, project.id)

      expect(found).to be_a(Order)
      expect(found.id).to eq(project.id)
    end
  end

  describe "#find_or_create_draft_for_owner" do
    it "reuses the latest draft or creates one" do
      client = workspace_account(:client)
      pm = workspace_account(:pm)
      draft = Project.create!(owner: client, participant: pm, status: :draft, name: "Draft")

      repository = described_class.new

      found = repository.find_or_create_draft_for_owner(client, pm)

      expect(found).to be_a(Order)
      expect(found.id).to eq(draft.id)
      expect { repository.find_or_create_draft_for_owner(workspace_account(:client, email: "new-client@example.com"), pm) }.to change(Project, :count).by(1)
    end
  end

  describe "#replace_selections" do
    it "replaces all order selections" do
      project = Project.create!(owner: workspace_account(:client), participant: workspace_account(:pm), name: "Selections", status: :draft)
      offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
      item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
      first_type = VideoType.create!(name: "First", description: "First edit", price_cents: 1000, output_format: "mp4")
      second_type = VideoType.create!(name: "Second", description: "Second edit", price_cents: 2000, output_format: "mp4")
      _first_variant = OfferVariant.create!(offer:, offer_item_type: item_type, key: "first", name: first_type.name, description: first_type.description, price_cents: first_type.price_cents, output_format: first_type.output_format)
      second_variant = OfferVariant.create!(offer:, offer_item_type: item_type, key: "second", name: second_type.name, description: second_type.description, price_cents: second_type.price_cents, output_format: second_type.output_format)
      project.video_type_selections.create!(video_type: first_type, quantity: 1)

      described_class.new.replace_selections(project, [
        { offer_variant_id: second_variant.id, quantity: 3 }
      ])

      expect(project.video_type_selections.pluck(:video_type_id, :quantity)).to contain_exactly([ second_type.id, 3 ])
    end
  end
end
