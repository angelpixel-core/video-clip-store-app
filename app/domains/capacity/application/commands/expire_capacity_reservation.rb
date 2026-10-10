module Capacity
  module Application
    module Commands
      class ExpireCapacityReservation
        def self.call(order_id:, repository: Capacity::Adapters::Persistence::CapacityReservation::Repository.new)
          new(order_id:, repository:).call
        end

        def initialize(order_id:, repository:)
          @order_id = order_id
          @repository = repository
        end

        def call
          reservation = repository.find_by_order_id(order_id)
          return missing_reservation_failure unless reservation.present?
          return Core::Result::Success.(data: { reservation: reservation }) if reservation.expired?

          return reservation_not_expired_failure unless Capacity::Domain::Policies::ReservationExpirationPolicy.expired?(reservation)

          reservation.expire!
          repository.save(reservation)

          Core::Result::Success.(data: { reservation: reservation })
        rescue Capacity::Domain::Errors::InvalidReservationTransition => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { order_id: order_id })
        end

        private

        attr_reader :order_id, :repository

        def missing_reservation_failure
          Core::Result::Failure.(message: "Capacity reservation not found for order #{order_id}", code: :reservation_not_found, data: { order_id: order_id })
        end

        def reservation_not_expired_failure
          Core::Result::Failure.(message: "Capacity reservation for order #{order_id} is not expired yet", code: :reservation_not_expired, data: { order_id: order_id })
        end
      end
    end
  end
end
