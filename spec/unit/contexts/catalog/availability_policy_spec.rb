require "rails_helper"

RSpec.describe Catalog::Domain::Policies::AvailabilityPolicy do
  it "evaluates the default capacity rule and enforces the requested quantity" do
    offer = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")

    allow(Capacity::Domain::Policies::CapacityCalculationPolicy).to receive(:available_units_for).with(offer).and_return(2)

    result = described_class.evaluate(offer, quantity: 2)

    expect(result).to be_a(Catalog::Domain::ValueObjects::Availability)
    expect(result.available?).to be(true)
    expect(result.reason).to be_nil
    expect(result.details[:available_units]).to eq(2)
    expect(described_class.available?(offer, quantity: 3)).to be(false)
  end

  it "accepts an injected rule set for marketplace-specific composition" do
    offer = instance_double(VideoType)
    passing_rule = instance_double("AvailabilityRule", evaluate: Catalog::Domain::ValueObjects::Availability.new(available: true, details: { rule: :passing }))
    failing_rule = instance_double("AvailabilityRule", evaluate: Catalog::Domain::ValueObjects::Availability.new(available: false, reason: :blocked, details: { rule: :failing }))
    rule_set = described_class::RuleSet.new(groups: [ [ passing_rule, failing_rule ], [ passing_rule ] ])

    result = described_class.evaluate(offer, quantity: 1, context: { marketplace: :default }, rule_set: rule_set)

    expect(result.available?).to be(true)
    expect(result.details[:rule]).to eq(:passing)
  end
end
