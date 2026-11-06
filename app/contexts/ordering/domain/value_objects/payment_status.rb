module Ordering
  module Domain
    module ValueObjects
      class PaymentStatus
        ALLOWED_VALUES = %w[unpaid pending paid failed refunded].freeze

        def self.valid?(value)
          ALLOWED_VALUES.include?(value.to_s)
        end

        def initialize(value)
          @value = value.to_s.strip.downcase
          raise ArgumentError, "Invalid payment status: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def unpaid?
          value == "unpaid"
        end

        def pending?
          value == "pending"
        end

        def paid?
          value == "paid"
        end

        def failed?
          value == "failed"
        end

        def refunded?
          value == "refunded"
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
