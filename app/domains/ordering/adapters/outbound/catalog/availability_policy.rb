module Ordering
  module Adapters
    module Outbound
      module Catalog
        class AvailabilityPolicy < Ordering::Application::Ports::AvailabilityPort
          def evaluate(...)
            ::Catalog::Domain::Policies::AvailabilityPolicy.evaluate(...)
          end
        end
      end
    end
  end
end
