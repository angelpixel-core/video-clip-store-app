require "securerandom"

module Ordering
  module Domain
    module ValueObjects
      class OrderNumber
        FORMAT = "ord_%<order_id>d_%<uuid>s".freeze
        PATTERN = /\Aord_(\d+)_([0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})\z/i

        def self.generate(order_id:, uuid: uuid_v7)
          new(compose(order_id:, uuid:))
        end

        def self.compose(order_id:, uuid:)
          format(FORMAT, order_id: OrderID.parse(order_id).to_i, uuid: uuid)
        end

        def self.valid?(value)
          PATTERN.match?(value.to_s)
        end

        def self.uuid_v7
          timestamp_ms = (Time.now.utc.to_f * 1000).to_i
          timestamp_bytes = [ timestamp_ms ].pack("Q>").bytes.last(6)
          random = SecureRandom.bytes(10).bytes

          bytes = []
          bytes.concat(timestamp_bytes)
          bytes << (0x70 | (random[0] & 0x0f))
          bytes << random[1]
          bytes << (0x80 | (random[2] & 0x3f))
          bytes.concat(random[3, 7])

          hex = bytes.map { |byte| byte.to_s(16).rjust(2, "0") }.join
          [ hex[0, 8], hex[8, 4], hex[12, 4], hex[16, 4], hex[20, 12] ].join("-")
        end

        def initialize(value)
          @value = value.to_s.strip
          raise ArgumentError, "Invalid order number: #{value.inspect}" unless self.class.valid?(@value)
        end

        def to_s
          value
        end

        def order_id
          value.match(PATTERN)[1].to_i
        end

        def uuid
          value.match(PATTERN)[2]
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
