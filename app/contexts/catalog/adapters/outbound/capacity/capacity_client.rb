module Catalog
  module Adapters
    module Outbound
      module Capacity
        class CapacityClient
          def self.call(offer:, quantity: 1)
            ::Capacity::Application::Queries::CheckCapacity.call(offer:, quantity:)
          end
        end
      end
    end
  end
end
