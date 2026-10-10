module Notifications
  module Application
    module Notifications
      module Channel
        class Email
          def initialize(deliveries)
            @deliveries = Array(deliveries)
          end

          def call
            deliveries.each(&:call)
          end

          private

          attr_reader :deliveries
        end
      end
    end
  end
end
