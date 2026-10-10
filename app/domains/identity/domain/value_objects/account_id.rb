module Identity
  module Domain
    module ValueObjects
      class AccountID
        def self.valid?(value)
          value.to_i.positive?
        end

        def initialize(value)
          @value = value.to_i
          raise ArgumentError, "Invalid account id: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_i
          value
        end

        def to_s
          value.to_s
        end

        def ==(other)
          other.to_i == value
        end

        private

        attr_reader :value
      end
    end
  end
end
