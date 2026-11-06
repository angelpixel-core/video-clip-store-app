module Ordering
  module Domain
    module Entities
      class LineItem
        attr_reader :offering_snapshot, :quantity

        def initialize(offering_snapshot:, quantity: 1)
          @offering_snapshot = build_offering_snapshot(offering_snapshot)
          @quantity = Integer(quantity)
          raise ArgumentError, "LineItem quantity must be positive" if @quantity <= 0
        rescue ArgumentError, TypeError
          raise ArgumentError, "Invalid line item quantity: #{quantity.inspect}"
        end

        def line_total_cents
          quantity * offering_snapshot.price_cents
        end

        def line_total
          Ordering::Domain::ValueObjects::OrderTotal.new(line_total_cents)
        end

        def to_h
          {
            offering_snapshot: offering_snapshot.to_h,
            quantity: quantity,
            line_total_cents: line_total_cents
          }
        end

        def ==(other)
          other.respond_to?(:to_h) && other.to_h == to_h
        end

        private

      def build_offering_snapshot(value)
          return value if value.is_a?(Ordering::Domain::Entities::OfferingSnapshot)

          Ordering::Domain::Entities::OfferingSnapshot.new(**value)
        end
      end
    end
  end
end
