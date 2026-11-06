module Ordering
  module Domain
    module Repositories
      module Order
        class Contract
          def find_by_id(_id)
            raise NotImplementedError, "#{self.class}#find_by_id must be implemented"
          end

          def find_by_uid(_uid)
            raise NotImplementedError, "#{self.class}#find_by_uid must be implemented"
          end

          def save(_order)
            raise NotImplementedError, "#{self.class}#save must be implemented"
          end

          def delete(_order)
            raise NotImplementedError, "#{self.class}#delete must be implemented"
          end
        end
      end
    end
  end
end
