module Capacity
  module Domain
    module Entities
      class CapacityReservation
        STATUSES = %w[reserved committed released expired].freeze

        attr_reader :order_id, :units, :status, :expires_at, :committed_at, :released_at, :expired_at, :created_at, :updated_at

        def self.reserve(order_id:, units:, expires_at: nil, at: Time.current)
          new(
            order_id:,
            units:,
            status: :reserved,
            expires_at:,
            created_at: at,
            updated_at: at
          )
        end

        def initialize(order_id:, units:, status: :reserved, expires_at: nil, committed_at: nil, released_at: nil, expired_at: nil, created_at: nil, updated_at: nil)
          @order_id = normalize_order_id(order_id)
          @units = normalize_units(units)
          @status = normalize_status(status)
          @expires_at = expires_at
          @committed_at = committed_at
          @released_at = released_at
          @expired_at = expired_at
          @created_at = created_at
          @updated_at = updated_at || created_at
        end

        def reserved?
          status == "reserved"
        end

        def committed?
          status == "committed"
        end

        def released?
          status == "released"
        end

        def expired?
          status == "expired"
        end

        def terminal?
          committed? || released? || expired?
        end

        def commit!(at: Time.current)
          ensure_reservable!
          @status = "committed"
          @committed_at = at
          touch!(at)
          self
        end

        def release!(at: Time.current)
          ensure_reservable!
          @status = "released"
          @released_at = at
          touch!(at)
          self
        end

        def expire!(at: Time.current)
          ensure_reservable!
          @status = "expired"
          @expired_at = at
          touch!(at)
          self
        end

        private

        def normalize_units(value)
          units = value.to_i
          raise ArgumentError, "Capacity reservation units must be positive" if units <= 0

          units
        end

        def normalize_order_id(value)
          order_id = value.to_i
          raise ArgumentError, "Capacity reservation order_id must be positive" if order_id <= 0

          order_id
        end

        def normalize_status(value)
          normalized = value.to_s.strip.downcase
          raise Capacity::Domain::Errors::InvalidReservationTransition, "Invalid reservation status: #{value.inspect}" unless STATUSES.include?(normalized)

          normalized
        end

        def ensure_reservable!
          return if reserved?

          raise Capacity::Domain::Errors::InvalidReservationTransition, "Capacity reservation cannot transition from #{status}"
        end

        def touch!(at)
          @updated_at = at
        end
      end
    end
  end
end
