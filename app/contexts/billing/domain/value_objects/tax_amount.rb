module Billing
  module Domain
    module ValueObjects
      class TaxAmount
        attr_reader :cents

        def initialize(cents)
          @cents = cents.to_i
        end

        def to_i
          cents
        end

        def zero?
          cents.zero?
        end
      end
    end
  end
end
