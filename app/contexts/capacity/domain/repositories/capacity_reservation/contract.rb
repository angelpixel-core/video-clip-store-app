module Capacity
  module Domain
    module Repositories
      module CapacityReservation
        class Contract
          def find_by_order_id(order_id)
            raise NotImplementedError
          end

          def save(reservation)
            raise NotImplementedError
          end

          def delete(reservation)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
