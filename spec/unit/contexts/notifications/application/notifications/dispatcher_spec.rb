require "rails_helper"

RSpec.describe Notifications::Application::Notifications::Dispatcher do
  it "calls every channel" do
    first = instance_double("Channel", call: true)
    second = instance_double("Channel", call: true)

    expect(first).to receive(:call)
    expect(second).to receive(:call)

    described_class.call(channels: [ first, second ])
  end
end
