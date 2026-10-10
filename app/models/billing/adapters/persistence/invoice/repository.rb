module Billing
  module Adapters
    module Persistence
      module Invoice
        class Repository < Billing::Domain::Repositories::InvoiceRepository
          def initialize(mapper: Mapper.new)
            @mapper = mapper
          end

          def find_by_id(id)
            mapper.to_domain(InvoiceRecord.find_by(id: id))
          end

          def find_by_number(number)
            mapper.to_domain(InvoiceRecord.find_by(number: number))
          end

          def save(invoice)
            record = mapper.to_record(invoice)
            record.save!
            mapper.to_domain(record)
          end

          private

          attr_reader :mapper
        end
      end
    end
  end
end
