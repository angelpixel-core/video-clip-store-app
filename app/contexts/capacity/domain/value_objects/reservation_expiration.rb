module Capacity
  module Domain
    module ValueObjects
      class ReservationExpiration
        def initialize(value)
          @value = value
        end

        def to_time
          value
        end

        private

        attr_reader :value
      end
    end
  end
end
