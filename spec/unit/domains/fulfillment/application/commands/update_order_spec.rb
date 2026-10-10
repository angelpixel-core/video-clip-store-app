require "rails_helper"

require Rails.root.join("app/domains/fulfillment/application/commands/update_order")

RSpec.describe Fulfillment::Application::Commands::UpdateOrder do
  it "delegates to autosave when finalize is false" do
    order = instance_double(Project)
    participant = instance_double(Identity::Domain::Aggregates::Account)
    attributes = { name: "Draft" }
    selections = []
    repository = instance_double("Repository")
    result = Core::Result::Success.(data: { order: order })

    expect(Fulfillment::Application::Commands::AutosaveDraftOrder).to receive(:call).with(order: order, participant: participant, attributes: attributes, selections: selections, repository: repository).and_return(result)

    expect(
      described_class.call(order: order, participant: participant, attributes: attributes, selections: selections, finalize: false, repository: repository)
    ).to eq(result)
  end

  it "delegates to submit when finalize is true" do
    order = instance_double(Project)
    participant = instance_double(Identity::Domain::Aggregates::Account)
    attributes = { name: "Final" }
    selections = []
    repository = instance_double("Repository")
    result = Core::Result::Failure.(message: "nope", code: :invalid_record)

    expect(Fulfillment::Application::Commands::SubmitOrder).to receive(:call).with(order: order, participant: participant, attributes: attributes, selections: selections, repository: repository).and_return(result)

    expect(
      described_class.call(order: order, participant: participant, attributes: attributes, selections: selections, finalize: true, repository: repository)
    ).to eq(result)
  end
end
