module Identity
  module Domain
    module Aggregates
      class User < Identity::Adapters::Persistence::User::UserRecord
      end
    end
  end
end
