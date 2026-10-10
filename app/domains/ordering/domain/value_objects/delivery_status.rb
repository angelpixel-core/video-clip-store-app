module Ordering
  module Domain
    module ValueObjects
      class DeliveryStatus
        ALLOWED_VALUES = %w[not_ready preparing ready delivered expired].freeze

        def self.valid?(value)
          ALLOWED_VALUES.include?(value.to_s)
        end

        def initialize(value)
          @value = value.to_s.strip.downcase
          raise ArgumentError, "Invalid delivery status: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def not_ready?
          value == "not_ready"
        end

        def preparing?
          value == "preparing"
        end

        def ready?
          value == "ready"
        end

        def delivered?
          value == "delivered"
        end

        def expired?
          value == "expired"
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
