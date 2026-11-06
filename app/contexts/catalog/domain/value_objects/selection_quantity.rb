module Catalog
  module Domain
    module ValueObjects
      class SelectionQuantity
        def initialize(value)
          @value = value.to_i
          raise ArgumentError, "Selection quantity must be positive" unless @value.positive?
        end

        def to_i
          value
        end

        private

        attr_reader :value
      end
    end
  end
end
