require "rails_helper"

RSpec.describe Notifications::Application::Notifications::Channel::Email do
  it "calls each channel" do
    first = double("Delivery")
    second = double("Delivery")

    expect(first).to receive(:call)
    expect(second).to receive(:call)

    described_class.new([ first, second ]).call
  end
end
