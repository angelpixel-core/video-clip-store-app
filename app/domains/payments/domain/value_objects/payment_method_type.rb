module Payments
  module Domain
    module ValueObjects
      class PaymentMethodType
        ALLOWED_VALUES = %w[card bank_transfer cash pix transfer].freeze

        def self.valid?(value)
          ALLOWED_VALUES.include?(value.to_s)
        end

        def initialize(value)
          @value = normalize(value)
          raise ArgumentError, "Invalid payment method type: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def ==(other)
          other.to_s == value
        end

        def card?
          value == "card"
        end

        def bank_transfer?
          value == "bank_transfer"
        end

        def cash?
          value == "cash"
        end

        def pix?
          value == "pix"
        end

        def transfer?
          value == "transfer"
        end

        private

        attr_reader :value

        def normalize(value)
          value.to_s.strip.downcase
        end
      end
    end
  end
end
