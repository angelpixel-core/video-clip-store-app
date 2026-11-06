module Identity
  module Domain
    module Entities
      class OperatorProfile
        attr_reader :account

        def initialize(account:)
          @account = account
        end
      end
    end
  end
end
