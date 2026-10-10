module Catalog
  module Domain
    module ValueObjects
      class OfferID
        def initialize(value)
          @value = value.to_i
          raise ArgumentError, "Invalid offer id: #{value.inspect}" unless @value.positive?
        end

        def to_i
          value
        end

        def to_s
          value.to_s
        end

        private

        attr_reader :value
      end
    end
  end
end
