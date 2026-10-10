module Payments
  module Application
    module Queries
      class FindPayment
        def self.call(id: nil, provider_reference: nil)
          new(id:, provider_reference:).call
        end

        def initialize(id: nil, provider_reference: nil)
          @id = id
          @provider_reference = provider_reference
        end

        def call
          payment = find_payment

          return Core::Result::Failure.(message: "Payment not found.", code: :not_found) if payment.blank?

          Core::Result::Success.(data: { payment: Payments::Application::DTO::PaymentDTO.from_payment(payment) })
        end

        private

        attr_reader :id, :provider_reference

        def find_payment
          return Payments::Domain::Repositories::PaymentRepository.find_by_id(id) if id.present?
          Payments::Domain::Repositories::PaymentRepository.find_by_provider_reference(provider_reference) if provider_reference.present?
        end
      end
    end
  end
end
