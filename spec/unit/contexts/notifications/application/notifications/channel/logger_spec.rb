require "rails_helper"

RSpec.describe Notifications::Application::Notifications::Channel::Logger do
  it "logs the provided message" do
    logger = instance_double(Logger)

    expect(logger).to receive(:info).with("Notification for project 123: project_created")

    described_class.new("Notification for project 123: project_created", logger: logger).call
  end
end
