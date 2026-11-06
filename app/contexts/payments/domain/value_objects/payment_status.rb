module Payments
  module Domain
    module ValueObjects
      class PaymentStatus
        ACTIVE_STATUSES = %w[pending processing].freeze
        TERMINAL_STATUSES = %w[succeeded failed canceled refunded].freeze
        ALLOWED_VALUES = (ACTIVE_STATUSES + TERMINAL_STATUSES).freeze

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

        def active?
          ACTIVE_STATUSES.include?(value)
        end

        def terminal?
          TERMINAL_STATUSES.include?(value)
        end

        def pending?
          value == "pending"
        end

        def processing?
          value == "processing"
        end

        def succeeded?
          value == "succeeded"
        end

        def failed?
          value == "failed"
        end

        def canceled?
          value == "canceled"
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
