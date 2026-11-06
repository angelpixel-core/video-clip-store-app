module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        def self.available?(offerable, quantity: 1, context: {}, rule_set: nil)
          evaluate(offerable, quantity:, context:, rule_set:).available?
        end

        def self.evaluate(offerable, quantity: 1, context: {}, rule_set: nil)
          (rule_set || default_rule_set).evaluate(offerable, quantity:, context:)
        end

        def self.default_rule_set
          RuleSet.new(groups: [ [ Rules::AvailabilityRule.new ] ])
        end
      end
    end
  end
end
