module Capacity
  module Domain
    module Aggregates
      class ProductionCapacity
        attr_reader :total_units, :reserved_units

        def initialize(total_units:, reserved_units: 0)
          @total_units = total_units.to_i
          @reserved_units = reserved_units.to_i
        end

        def available_units
          [ total_units - reserved_units, 0 ].max
        end
      end
    end
  end
end
