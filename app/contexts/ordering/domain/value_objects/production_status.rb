module Ordering
  module Domain
    module ValueObjects
      class ProductionStatus
        ALLOWED_VALUES = %w[not_started queued in_progress review completed blocked].freeze

        def self.valid?(value)
          ALLOWED_VALUES.include?(value.to_s)
        end

        def initialize(value)
          @value = value.to_s.strip.downcase
          raise ArgumentError, "Invalid production status: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def not_started?
          value == "not_started"
        end

        def queued?
          value == "queued"
        end

        def in_progress?
          value == "in_progress"
        end

        def review?
          value == "review"
        end

        def completed?
          value == "completed"
        end

        def blocked?
          value == "blocked"
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
