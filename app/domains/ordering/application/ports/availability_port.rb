module Ordering
  module Application
    module Ports
      class AvailabilityPort < Core::Services::Provider
        def evaluate(...)
          raise NotImplementedError, "Use a concrete availability port"
        end
      end
    end
  end
end
