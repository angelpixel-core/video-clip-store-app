module Capacity
  module Domain
    module Events
      class CapacityReserved
        attr_reader :reservation

        def initialize(reservation:)
          @reservation = reservation
        end
      end
    end
  end
end
