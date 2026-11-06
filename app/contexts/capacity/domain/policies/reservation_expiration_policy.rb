module Capacity
  module Domain
    module Policies
      class ReservationExpirationPolicy
        def self.expired?(reservation)
          reservation.respond_to?(:expires_at) && reservation.expires_at.present? && reservation.expires_at < Time.current
        end
      end
    end
  end
end
