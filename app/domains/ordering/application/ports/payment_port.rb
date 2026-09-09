module Ordering
  module Application
    module Ports
      class PaymentPort < Core::Services::Provider
        def call(...)
          raise NotImplementedError, "Use a concrete payment port"
        end
      end
    end
  end
end
