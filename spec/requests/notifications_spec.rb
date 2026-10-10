require "rails_helper"

RSpec.describe "Notifications requests" do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"]
    original_pm = ENV["DEFAULT_PM_WORKSPACE_EMAIL"]

    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com"

    example.run

    restore_env("DEFAULT_CLIENT_WORKSPACE_EMAIL", original_client)
    restore_env("DEFAULT_PM_WORKSPACE_EMAIL", original_pm)
  end

  before do
    workspace_account(:client, name: "Default Client", email: "client@example.com")
    workspace_account(:pm, name: "Default PM", email: "pm@example.com")
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end

  it "marks a client notification as read" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = Notification.create!(project: project, client: client, kind: "project_status_changed", body: "Order updated")

    patch notification_path(notification)

    expect(response).to have_http_status(:no_content)
    expect(notification.reload.read_at).to be_present
  end
end
