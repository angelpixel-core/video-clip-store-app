require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "fails when there are no line items" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    submission = Ordering::Application::DTO::Submission.from_order(project, fulfillment_account: pm)

    result = described_class.call(
      submission: submission,
      payment_command: lambda { |_args| raise "payment should not be called" }
    )

    expect(result).to be_failure
    expect(result.message).to eq("Submission requires at least one line item")
  end
end
