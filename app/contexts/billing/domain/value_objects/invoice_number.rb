module Billing
  module Domain
    module ValueObjects
      class InvoiceNumber
        attr_reader :value

        def initialize(value)
          @value = value.to_s.strip
        end

        def to_s
          value
        end
      end
    end
  end
end
