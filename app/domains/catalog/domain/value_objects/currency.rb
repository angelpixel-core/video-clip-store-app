module Catalog
  module Domain
    module ValueObjects
      class Currency
        def initialize(value)
          @value = value.to_s.strip.upcase
          raise ArgumentError, "Currency cannot be blank" if @value.blank?
        end

        def to_s
          value
        end

        private

        attr_reader :value
      end
    end
  end
end
