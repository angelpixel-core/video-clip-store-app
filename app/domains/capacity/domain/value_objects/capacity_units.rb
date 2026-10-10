module Capacity
  module Domain
    module ValueObjects
      class CapacityUnits
        def initialize(value)
          @value = value.to_i
          raise ArgumentError, "Capacity units must be non-negative" if @value.negative?
        end

        def to_i
          value
        end

        private

        attr_reader :value
      end
    end
  end
end
