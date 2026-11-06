module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        module Rules
          class VariantRule
            def initialize(allowed_variant_ids: nil, allowed_variant_keys: nil)
              @allowed_variant_ids = Array(allowed_variant_ids).compact
              @allowed_variant_keys = Array(allowed_variant_keys).compact.map(&:to_s)
            end

            def evaluate(offerable, quantity:, context: {})
              return availability(true, quantity:, context:) if allowed_variant_ids.empty? && allowed_variant_keys.empty?

              variant_id = offerable.respond_to?(:id) ? offerable.id : nil
              variant_key = offerable.respond_to?(:key) ? offerable.key.to_s : nil
              allowed = allowed_variant_ids.include?(variant_id) || allowed_variant_keys.include?(variant_key)

              availability(allowed, quantity:, context:, reason: :variant_not_allowed, details: { variant_id: variant_id, variant_key: variant_key })
            end

            private

            attr_reader :allowed_variant_ids, :allowed_variant_keys

            def availability(available, quantity:, context:, reason: nil, details: {})
              Catalog::Domain::ValueObjects::Availability.new(
                available: available,
                reason: available ? nil : reason,
                details: details.merge(quantity: quantity.to_i, context: context)
              )
            end
          end
        end
      end
    end
  end
end
