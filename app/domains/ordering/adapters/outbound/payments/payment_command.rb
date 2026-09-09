module Ordering
  module Adapters
    module Outbound
      module Payments
        class PaymentCommand < Ordering::Application::Ports::PaymentPort
          def call(...)
            ::Payments::Application::Commands::CreatePayment.call(...)
          end
        end
      end
    end
  end
end
