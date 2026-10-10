module Payments
  module Adapters
    module Persistence
      module Payment
        class Repository
          def self.find_by_id(id)
            Payments::Domain::Aggregates::Payment.find_by(id: id)
          end

          def self.find_by_provider_reference(provider_reference)
            Payments::Domain::Aggregates::Payment.find_by(provider_reference: provider_reference)
          end
        end
      end
    end
  end
end
