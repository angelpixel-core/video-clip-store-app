require "rails_helper"

RSpec.describe NotificationJob do
  it "delegates to the order notification service" do
    order = Order.create!(
      owner: workspace_account(:client, name: "Client"),
      participant: workspace_account(:pm, name: "PM"),
      name: "Project",
      raw_footage_url: "https://example.com/raw.mov",
      status: :in_progress
    )

    service = instance_double(Orders::Notifications::Service)
    expect(Orders::Notifications::Service).to receive(:call).with(project: order, event_type: :project_created).and_return(service)

    described_class.perform_now(order.id)
  end
end
