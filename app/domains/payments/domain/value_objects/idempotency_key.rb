module Payments
  module Domain
    module ValueObjects
      class IdempotencyKey
        def initialize(value)
          @value = value.to_s.strip
          raise ArgumentError, "Idempotency key cannot be blank" if @value.blank?
        end

        def to_s
          value
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
