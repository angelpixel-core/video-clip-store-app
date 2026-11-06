module Identity
  module Domain
    module Entities
      class EditorProfile
        attr_reader :account

        def initialize(account:)
          @account = account
        end
      end
    end
  end
end
