module Capacity
  module Adapters
    module Outbound
      module Catalog
        class CatalogReader
          def self.available_units_for(offer)
            Capacity::Domain::Policies::CapacityCalculationPolicy.available_units_for(offer)
          end
        end
      end
    end
  end
end
