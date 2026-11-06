module Identity
  module Domain
    module Repositories
      module Account
        class Contract
          def find_by_email(_email)
            raise NotImplementedError, "#{self.class}#find_by_email must be implemented"
          end

          def find_by_email_and_role(_email, _role)
            raise NotImplementedError, "#{self.class}#find_by_email_and_role must be implemented"
          end

          def find_by_role(_role)
            raise NotImplementedError, "#{self.class}#find_by_role must be implemented"
          end

          def find_by_user(_user)
            raise NotImplementedError, "#{self.class}#find_by_user must be implemented"
          end

          def find_by_user_and_role(_user, _role)
            raise NotImplementedError, "#{self.class}#find_by_user_and_role must be implemented"
          end
        end
      end
    end
  end
end
