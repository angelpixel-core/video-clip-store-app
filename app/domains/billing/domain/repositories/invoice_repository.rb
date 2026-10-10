module Billing
  module Domain
    module Repositories
      class InvoiceRepository
        def find_by_id(_id)
          raise NotImplementedError, "#{self.class} must implement #find_by_id"
        end

        def find_by_number(_number)
          raise NotImplementedError, "#{self.class} must implement #find_by_number"
        end

        def save(_invoice)
          raise NotImplementedError, "#{self.class} must implement #save"
        end
      end
    end
  end
end
