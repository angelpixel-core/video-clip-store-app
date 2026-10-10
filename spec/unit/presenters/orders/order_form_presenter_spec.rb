require "rails_helper"

RSpec.describe Orders::OrderFormPresenter do
  let(:project) { instance_double(Project, draft?: true) }

  it "builds the project param namespace and uses draft copy" do
    presenter = described_class.new(project:, path: "/orders/8")

    expect(presenter.title).to eq("Resume draft")
    expect(presenter.param_key).to eq(:project)
    expect(presenter.path).to eq("/orders/8")
    expect(presenter.field_name(:selections_json)).to eq("project[selections_json]")
    expect(presenter.fields.name_label).to eq("Name")
  end

  it "uses the new-order title when requested" do
    presenter = described_class.new(project:, path: "/orders", context: :new)

    expect(presenter.title).to eq("Create a new order")
  end
end
