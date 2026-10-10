require "rails_helper"

RSpec.describe Orders::Notifications::Service do
  it "creates a notification and delivers emails to client and pm" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_created).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_created).with(project, recipient_role: :pm).and_return(pm_mail)

    expect do
      described_class.call(project: project, event_type: :project_created)
    end.to change(Notification, :count).by(1)

    notification = Notification.order(:created_at).last

    expect(notification.pm).to eq(pm)
    expect(notification.kind).to eq("project_created")
    expect(notification.body).to include("submitted for review")
  end
end
