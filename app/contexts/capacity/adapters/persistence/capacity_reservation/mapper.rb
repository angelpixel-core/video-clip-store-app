module Capacity
  module Adapters
    module Persistence
      module CapacityReservation
        class Mapper
          def to_domain(record)
            Capacity::Domain::Entities::CapacityReservation.new(
              order_id: record.order_id,
              units: record.units,
              status: record.status,
              expires_at: record.expires_at,
              committed_at: record.committed_at,
              released_at: record.released_at,
              expired_at: record.expired_at,
              created_at: record.created_at,
              updated_at: record.updated_at
            )
          end

          def write(reservation, record)
            record.order_id = reservation.order_id
            record.units = reservation.units
            record.status = reservation.status
            record.expires_at = reservation.expires_at
            record.committed_at = reservation.committed_at
            record.released_at = reservation.released_at
            record.expired_at = reservation.expired_at
            record
          end
        end
      end
    end
  end
end
