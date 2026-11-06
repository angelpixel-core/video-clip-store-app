module Ordering
  module Domain
    module ValueObjects
      class EditingInstructions
        def initialize(value)
          @value = value.to_s.strip
        end

        def to_s
          value
        end

        def blank?
          value.empty?
        end

        def ==(other)
          other.to_s == value
        end

        private

        attr_reader :value
      end
    end
  end
end
