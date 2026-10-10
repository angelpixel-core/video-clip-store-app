module Catalog
  module Domain
    module Entities
      class OfferingVariant < Catalog::Domain::Aggregates::Offering
        def available?
          Catalog::Domain::Policies::AvailabilityPolicy.available?(self)
        end
      end
    end
  end
end
