require "rails_helper"

RSpec.describe Catalog::Domain::Policies::AvailabilityPolicy::RuleSet do
  it "treats groups as OR and rules inside a group as AND" do
    offerable = instance_double(VideoType)
    pass_rule = instance_double("AvailabilityRule", evaluate: Catalog::Domain::ValueObjects::Availability.new(available: true, details: { rule: :pass }))
    fail_rule = instance_double("AvailabilityRule", evaluate: Catalog::Domain::ValueObjects::Availability.new(available: false, reason: :blocked, details: { rule: :fail }))
    rule_set = described_class.new(groups: [ [ pass_rule, fail_rule ], [ pass_rule ] ])

    result = rule_set.evaluate(offerable, quantity: 1, context: {})

    expect(result.available?).to be(true)
    expect(result.reason).to be_nil
  end

  it "returns the first failure when every group fails" do
    offerable = instance_double(VideoType)
    fail_one = instance_double("AvailabilityRule", evaluate: Catalog::Domain::ValueObjects::Availability.new(available: false, reason: :first_blocked))
    fail_two = instance_double("AvailabilityRule", evaluate: Catalog::Domain::ValueObjects::Availability.new(available: false, reason: :second_blocked))
    rule_set = described_class.new(groups: [ [ fail_one ], [ fail_two ] ])

    result = rule_set.evaluate(offerable, quantity: 1, context: {})

    expect(result.available?).to be(false)
    expect(result.reason).to eq(:first_blocked)
  end
end
