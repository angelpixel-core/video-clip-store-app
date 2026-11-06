module Catalog
  module Domain
    module Policies
      class VisibilityPolicy
        def self.visible_to?(account, _offer)
          account.present? && (account.client? || account.pm? || account.role.to_s == "admin")
        end
      end
    end
  end
end
