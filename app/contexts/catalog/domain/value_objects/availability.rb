module Catalog
  module Domain
    module ValueObjects
      class Availability
        attr_reader :available, :reason, :details

        def initialize(available:, reason: nil, details: {})
          @available = !!available
          @reason = reason
          @details = (details || {}).dup.freeze
        end

        def available?
          available
        end

        def unavailable?
          !available?
        end
      end
    end
  end
end
