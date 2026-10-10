module Ordering
  module Domain
    module ValueObjects
      class OrderID
        def self.parse(value)
          new(value)
        end

        def initialize(value)
          @value = Integer(value)
          raise ArgumentError, "OrderID must be positive" if @value <= 0
        rescue ArgumentError, TypeError
          raise ArgumentError, "Invalid order id: #{value.inspect}"
        end

        def to_i
          value
        end

        def to_s
          value.to_s
        end

        def ==(other)
          other.to_i == value
        end

        private

        attr_reader :value
      end
    end
  end
end
