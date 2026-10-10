module Capacity
  module Domain
    module Policies
      class CapacityCalculationPolicy
        DEFAULT_TOTAL_UNITS = 100

        def self.available_units_for(_offer)
          total_units = ENV.fetch("CAPACITY_TOTAL_UNITS", DEFAULT_TOTAL_UNITS).to_i
          reserved_units = active_order_units + active_reservation_units

          Capacity::Domain::Aggregates::ProductionCapacity
            .new(total_units:, reserved_units:)
            .available_units
        end

        def self.active_order_units
          Ordering::Adapters::Persistence::Order::OrderRecord
            .where(status: %w[placed confirmed])
            .joins(:order_line_records)
            .sum("order_lines.quantity")
            .to_i
        end

        def self.active_reservation_units
          Capacity::Adapters::Persistence::CapacityReservation::CapacityReservationRecord
            .where(status: "reserved")
            .sum(:units)
            .to_i
        end
      end
    end
  end
end
