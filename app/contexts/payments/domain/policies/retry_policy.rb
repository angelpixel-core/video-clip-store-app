module Payments
  module Domain
    module Policies
      class RetryPolicy
        MAX_ATTEMPTS = 3

        def self.retryable?(attempt_number)
          attempt_number.to_i < MAX_ATTEMPTS
        end
      end
    end
  end
end
