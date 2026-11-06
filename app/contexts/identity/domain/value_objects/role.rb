module Identity
  module Domain
    module ValueObjects
      class Role
        ALLOWED_VALUES = %w[client pm].freeze

        def self.valid?(value)
          ALLOWED_VALUES.include?(value.to_s)
        end

        def initialize(value)
          @value = value.to_s.strip.downcase
          raise ArgumentError, "Invalid role: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def client?
          value == "client"
        end

        def pm?
          value == "pm"
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
