module Capacity
  module Domain
    module Events
      class CapacityUnavailable
        attr_reader :offer

        def initialize(offer:)
          @offer = offer
        end
      end
    end
  end
end
