module Catalog
  module Domain
    module ValueObjects
      class Price
        def initialize(cents)
          @cents = cents.to_i
          raise ArgumentError, "Price must be non-negative" if @cents.negative?
        end

        def to_i
          cents
        end

        def to_s
          cents.to_s
        end

        private

        attr_reader :cents
      end
    end
  end
end
