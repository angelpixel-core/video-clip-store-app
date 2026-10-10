module Catalog
  module Domain
    module ValueObjects
      class Duration
        def initialize(seconds)
          @seconds = seconds.to_i
          raise ArgumentError, "Duration must be positive" unless @seconds.positive?
        end

        def to_i
          seconds
        end

        private

        attr_reader :seconds
      end
    end
  end
end
