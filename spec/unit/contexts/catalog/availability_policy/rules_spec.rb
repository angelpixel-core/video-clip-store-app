require "rails_helper"

RSpec.describe "Availability policy rules" do
  it "evaluates variant-level availability" do
    variant = instance_double("Variant", id: 11, key: "highlight_reel")
    rule = Catalog::Domain::Policies::AvailabilityPolicy::Rules::VariantRule.new(allowed_variant_keys: [ "highlight_reel" ])

    result = rule.evaluate(variant, quantity: 1, context: {})

    expect(result.available?).to be(true)
  end

  it "evaluates offer-level availability" do
    offer = instance_double("Offer", id: 22, key: "video_editing")
    variant = instance_double("Variant", offer: offer)
    rule = Catalog::Domain::Policies::AvailabilityPolicy::Rules::OfferRule.new(allowed_offer_keys: [ "video_editing" ])

    result = rule.evaluate(variant, quantity: 1, context: {})

    expect(result.available?).to be(true)
  end

  it "evaluates resource-level availability" do
    rule = Catalog::Domain::Policies::AvailabilityPolicy::Rules::ResourceRule.new(resource_key: :editor_slot, minimum_units: 2)

    available = rule.evaluate(instance_double("Variant"), quantity: 1, context: { resources: { editor_slot: 2 } })
    unavailable = rule.evaluate(instance_double("Variant"), quantity: 2, context: { resources: { editor_slot: 2 } })

    expect(available.available?).to be(true)
    expect(unavailable.available?).to be(false)
    expect(unavailable.reason).to eq(:resource_unavailable)
  end

  it "composes variant, offer, and resource rules" do
    offer = instance_double("Offer", id: 22, key: "video_editing")
    variant = instance_double("Variant", id: 11, key: "highlight_reel", offer: offer)
    variant_rule = Catalog::Domain::Policies::AvailabilityPolicy::Rules::VariantRule.new(allowed_variant_keys: [ "highlight_reel" ])
    offer_rule = Catalog::Domain::Policies::AvailabilityPolicy::Rules::OfferRule.new(allowed_offer_keys: [ "video_editing" ])
    resource_rule = Catalog::Domain::Policies::AvailabilityPolicy::Rules::ResourceRule.new(resource_key: :editor_slot, minimum_units: 1)
    rule_set = Catalog::Domain::Policies::AvailabilityPolicy::RuleSet.new(groups: [ [ variant_rule, offer_rule, resource_rule ] ])

    result = rule_set.evaluate(variant, quantity: 1, context: { resources: { editor_slot: 1 } })

    expect(result.available?).to be(true)
  end
end
