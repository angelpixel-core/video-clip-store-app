require "rails_helper"

RSpec.describe Comment do
  it "requires a project, an author account, and a body" do
    comment = described_class.new

    expect(comment).not_to be_valid
    expect(comment.errors[:project]).to be_present
    expect(comment.errors[:author_account]).to be_present
    expect(comment.errors[:body]).to be_present
  end

  it "broadcasts project comment refreshes after create" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(ActionCable.server).to receive(:broadcast).with(
      "order_comments_#{project.id}",
      hash_including(
        type: "comments_updated",
        comment_count: 1,
        comment_html: a_string_including("Hello")
      )
    )
    described_class.create!(project: project, author_account: client, body: "Hello")
  end
end
