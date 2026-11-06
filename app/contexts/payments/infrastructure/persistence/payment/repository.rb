module Payments
  module Infrastructure
    module Persistence
      module Payment
        class Repository
          def initialize(mapper: Mapper.new)
            @mapper = mapper
          end

          def find_by_id(id)
            record = PaymentRecord.find_by(id: id)
            return unless record

            mapper.to_domain(record)
          end

          def find_by_provider_reference(provider_reference)
            record = PaymentRecord.find_by(provider_reference: provider_reference)
            return unless record

            mapper.to_domain(record)
          end

          def save(payment)
            record = mapper.to_record(payment)
            record.save!
            mapper.to_domain(record)
          end

          def self.find_by_id(id)
            PaymentRecord.find_by(id: id)
          end

          def self.find_by_provider_reference(provider_reference)
            PaymentRecord.find_by(provider_reference: provider_reference)
          end

          private

          attr_reader :mapper
        end
      end
    end
  end
end
