module Capacity
  module Infrastructure
    module Persistence
      module CapacityReservation
        class CapacityReservationRecord < ApplicationRecord
          self.table_name = "capacity_reservations"

          belongs_to :order_record, class_name: "Ordering::Infrastructure::Persistence::Order::OrderRecord", foreign_key: :order_id, inverse_of: nil
        end
      end
    end
  end
end
