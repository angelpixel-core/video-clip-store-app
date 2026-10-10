require "rails_helper"

RSpec.describe "Comments requests" do
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

  it "creates a comment as the client workspace" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect do
      post order_comments_path(project), params: {
        comment: {
          body: "Client note",
          author_role: "client"
        }
      }
    end.to change(Comment, :count).by(1)

    comment = Comment.order(:created_at).last

    expect(response).to redirect_to(order_path(project, anchor: "order-comments"))
    expect(comment.project.id).to eq(project.id)
    expect(comment.author).to eq(client)
    expect(comment.body).to eq("Client note")

    notification = Notification.order(:created_at).last
    expect(notification.client).to be_nil
    expect(notification.pm).to eq(pm)
    expect(notification.kind).to eq("comment_created")
  end

  it "creates a comment as the pm workspace" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Beta", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect do
      post order_comments_path(project), params: {
        comment: {
          body: "PM note",
          author_role: "pm"
        }
      }
    end.to change(Comment, :count).by(1)

    comment = Comment.order(:created_at).last

    expect(response).to redirect_to(order_path(project, anchor: "order-comments"))
    expect(comment.project.id).to eq(project.id)
    expect(comment.author).to eq(pm)
    expect(comment.body).to eq("PM note")

    notification = Notification.order(:created_at).last
    expect(notification.pm).to be_nil
    expect(notification.client).to eq(client)
    expect(notification.kind).to eq("comment_created")
  end
end
