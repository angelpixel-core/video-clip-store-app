module Billing
  module Domain
    module Policies
      class InvoiceGenerationPolicy
        def self.allow?(payment:, invoice: nil)
          new(payment:, invoice:).allow?
        end

        def initialize(payment:, invoice: nil)
          @payment = payment
          @invoice = invoice
        end

        def allow?
          payment.present? && payment.succeeded? && invoice.blank?
        end

        private

        attr_reader :payment, :invoice
      end
    end
  end
end
