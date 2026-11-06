module Ordering
  module Domain
    module ValueObjects
      class OrderStatus
        ALLOWED_VALUES = %w[draft placed confirmed cancelled completed].freeze

        def self.valid?(value)
          ALLOWED_VALUES.include?(value.to_s)
        end

        def initialize(value)
          @value = value.to_s.strip.downcase
          raise ArgumentError, "Invalid order status: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def draft?
          value == "draft"
        end

        def placed?
          value == "placed"
        end

        def confirmed?
          value == "confirmed"
        end

        def cancelled?
          value == "cancelled"
        end

        def completed?
          value == "completed"
        end

        def ==(other)
          other.to_s == value
        end

        private

        attr_reader :value
      end
    end
  end
end
