module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        class RuleSet
          def initialize(groups:)
            @groups = Array(groups).map { |group| Array(group) }
          end

          def evaluate(offerable, quantity:, context: {})
            return Catalog::Domain::ValueObjects::Availability.new(available: true, details: { rule_set: :empty }) if groups.empty?

            first_failure = nil

            groups.each do |group|
              result = evaluate_group(group, offerable, quantity:, context:)
              return result if result.available?

              first_failure ||= result
            end

            first_failure || Catalog::Domain::ValueObjects::Availability.new(available: true, details: { rule_set: :empty })
          end

          private

          attr_reader :groups

          def evaluate_group(group, offerable, quantity:, context:)
            return Catalog::Domain::ValueObjects::Availability.new(available: true, details: { rules: [] }) if group.empty?

            last_success = nil

            group.each do |rule|
              result = evaluate_rule(rule, offerable, quantity:, context:)
              return result if result.unavailable?

              last_success = result
            end

            last_success || Catalog::Domain::ValueObjects::Availability.new(available: true, details: { rules: group.size })
          end

          def evaluate_rule(rule, offerable, quantity:, context:)
            unless rule.respond_to?(:evaluate)
              raise ArgumentError, "Availability rules must respond to #evaluate"
            end

            rule.evaluate(offerable, quantity:, context:)
          end
        end
      end
    end
  end
end
