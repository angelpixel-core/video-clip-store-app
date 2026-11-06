module Capacity
  module Adapters
    module Persistence
      module CapacityReservation
        class Repository < Capacity::Domain::Repositories::CapacityReservation::Contract
          def initialize(mapper: Mapper.new)
            @mapper = mapper
          end

          def find_by_order_id(order_id)
            record = CapacityReservationRecord.find_by(order_id: order_id)
            return unless record

            mapper.to_domain(record)
          end

          def save(reservation)
            record = CapacityReservationRecord.find_or_initialize_by(order_id: reservation.order_id)
            mapper.write(reservation, record)
            record.save!
            reservation
          end

          def delete(reservation)
            record = CapacityReservationRecord.find_by(order_id: reservation.order_id)
            record&.destroy!
          end

          private

          attr_reader :mapper
        end
      end
    end
  end
end
