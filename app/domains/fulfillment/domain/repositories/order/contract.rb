module Fulfillment
  module Domain
    module Repositories
      module Order
        class Contract
          def find_for_show(_id)
            raise NotImplementedError, "#{self.class}#find_for_show must be implemented"
          end

          def find_for_edit(_owner, _id)
            raise NotImplementedError, "#{self.class}#find_for_edit must be implemented"
          end

          def find_for_workspace_action(_participant, _id)
            raise NotImplementedError, "#{self.class}#find_for_workspace_action must be implemented"
          end

          def find_or_create_draft_for_owner(_owner, _participant)
            raise NotImplementedError, "#{self.class}#find_or_create_draft_for_owner must be implemented"
          end

          def replace_selections(_order, _selections)
            raise NotImplementedError, "#{self.class}#replace_selections must be implemented"
          end
        end
      end
    end
  end
end
