module Catalog
  module Domain
    module ValueObjects
      class OfferName
        def initialize(value)
          @value = value.to_s.strip
          raise ArgumentError, "Offer name cannot be blank" if @value.blank?
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
