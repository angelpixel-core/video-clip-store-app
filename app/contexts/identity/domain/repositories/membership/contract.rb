module Identity
  module Domain
    module Repositories
      module Membership
        class Contract
          def find_by_user(_user)
            raise NotImplementedError, "#{self.class}#find_by_user must be implemented"
          end

          def find_by_account(_account)
            raise NotImplementedError, "#{self.class}#find_by_account must be implemented"
          end

          def find_by_user_and_account(_user, _account)
            raise NotImplementedError, "#{self.class}#find_by_user_and_account must be implemented"
          end

          def save(_membership)
            raise NotImplementedError, "#{self.class}#save must be implemented"
          end
        end
      end
    end
  end
end
