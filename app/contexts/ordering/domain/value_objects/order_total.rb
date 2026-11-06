module Ordering
  module Domain
    module ValueObjects
      class OrderTotal
        def self.from_lines(lines)
          new(Array(lines).sum(&:line_total_cents))
        end

        def initialize(cents)
          @cents = Integer(cents)
          raise ArgumentError, "OrderTotal must be non-negative" if @cents.negative?
        rescue ArgumentError, TypeError
          raise ArgumentError, "Invalid order total: #{cents.inspect}"
        end

        def to_i
          cents
        end

        def to_s
          cents.to_s
        end

        def +(other)
          self.class.new(cents + other.to_i)
        end

        def zero?
          cents.zero?
        end

        def ==(other)
          other.to_i == cents
        end

        private

        attr_reader :cents
      end
    end
  end
end
