module Capacity
  module Domain
    module Entities
      class CapacityPeriod
        attr_reader :starts_at, :ends_at

        def initialize(starts_at:, ends_at:)
          @starts_at = starts_at
          @ends_at = ends_at
        end
      end
    end
  end
end
