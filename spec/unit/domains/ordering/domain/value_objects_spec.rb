require "rails_helper"

RSpec.describe "Ordering value objects" do
  it "generates a hybrid order number" do
    number = Ordering::Domain::ValueObjects::OrderNumber.generate(order_id: 42)

    expect(number.to_s).to match(/\Aord_42_[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
    expect(number.order_id).to eq(42)
    expect(Ordering::Domain::ValueObjects::OrderNumber.compose(order_id: 42, uuid: "00000000-0000-7000-8000-000000000000")).to eq("ord_42_00000000-0000-7000-8000-000000000000")
  end

  it "tracks order and fulfillment status values" do
    expect(Ordering::Domain::ValueObjects::OrderStatus.new(:draft)).to be_draft
    expect(Ordering::Domain::ValueObjects::PaymentStatus.new(:paid)).to be_paid
    expect(Ordering::Domain::ValueObjects::ProductionStatus.new(:in_progress)).to be_in_progress
    expect(Ordering::Domain::ValueObjects::DeliveryStatus.new(:ready)).to be_ready
  end

  it "validates source urls" do
    expect(Ordering::Domain::ValueObjects::SourceUrl.new("https://example.com/video.mov").to_s).to eq("https://example.com/video.mov")
  end

  it "calculates order totals" do
    total = Ordering::Domain::ValueObjects::OrderTotal.new(25_000)

    expect(total.to_i).to eq(25_000)
    expect(total).to eq(Ordering::Domain::ValueObjects::OrderTotal.new(25_000))
  end
end
