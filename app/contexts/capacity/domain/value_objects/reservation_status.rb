module Capacity
  module Domain
    module ValueObjects
      class ReservationStatus
        VALUES = %w[reserved committed released expired].freeze

        def initialize(value)
          @value = value.to_s.strip.downcase
          raise ArgumentError, "Invalid reservation status" unless VALUES.include?(@value)
        end

        def to_s
          value
        end

        private

        attr_reader :value
      end
    end
  end
end
