module Identity
  module Adapters
    module Persistence
      module Account
        class Mapper
          def to_domain(record)
            return if record.nil?

            Identity::Domain::Aggregates::Account.find(record.id)
          end

          def scope_for(role)
            normalized_role = role.to_s.strip.downcase
            Identity::Domain::Aggregates::Account.where(role: normalized_role)
          end
        end
      end
    end
  end
end
