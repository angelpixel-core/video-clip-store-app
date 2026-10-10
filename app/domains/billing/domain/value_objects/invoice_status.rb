module Billing
  module Domain
    module ValueObjects
      class InvoiceStatus
        ALLOWED_VALUES = %w[draft issued paid void failed].freeze

        attr_reader :value

        def initialize(value)
          normalized = value.to_s.strip.downcase
          @value = ALLOWED_VALUES.include?(normalized) ? normalized : "issued"
        end

        def to_s
          value
        end
      end
    end
  end
end
