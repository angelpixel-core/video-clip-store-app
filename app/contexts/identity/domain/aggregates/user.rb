module Identity
  module Domain
    module Aggregates
      class User < Identity::Infrastructure::Persistence::User::UserRecord
      end
    end
  end
end
