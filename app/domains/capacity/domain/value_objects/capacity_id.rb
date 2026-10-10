module Capacity
  module Domain
    module ValueObjects
      class CapacityID
        def initialize(value)
          @value = value.to_i
          raise ArgumentError, "Invalid capacity id" unless @value.positive?
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
