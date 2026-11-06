module Capacity
  module Application
    module Commands
      class ReserveCapacity
        def self.call(order_id:, units:, expires_at: nil, repository: Capacity::Adapters::Persistence::CapacityReservation::Repository.new)
          new(order_id:, units:, expires_at:, repository:).call
        end

        def initialize(order_id:, units:, expires_at: nil, repository:)
          @order_id = order_id
          @units = units
          @expires_at = expires_at
          @repository = repository
        end

        def call
          existing = repository.find_by_order_id(order_id)
          return Core::Result::Success.(data: { reservation: existing }) if existing.present? && existing.reserved? && existing.units == units.to_i

          return conflict_failure(existing) if existing.present?

          reservation = Capacity::Domain::Entities::CapacityReservation.reserve(order_id:, units:, expires_at:)
          repository.save(reservation)

          Core::Result::Success.(data: { reservation: reservation })
        rescue Capacity::Domain::Errors::InvalidReservationTransition, ArgumentError => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { order_id: order_id })
        end

        private

        attr_reader :order_id, :units, :expires_at, :repository

        def conflict_failure(existing)
          Core::Result::Failure.(message: "Capacity reservation already exists for order #{order_id}", code: :reservation_conflict, data: { reservation: existing, order_id: order_id })
        end
      end
    end
  end
end
