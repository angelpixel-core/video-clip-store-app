module Billing
  module Application
    module Commands
      class MarkInvoicePaid
        def self.call(invoice_number:, repository: nil)
          new(invoice_number:, repository:).call
        end

        def initialize(invoice_number:, repository: nil)
          @invoice_number = invoice_number.to_s.strip
          @repository = repository || Billing::Adapters::Persistence::Invoice::Repository.new
        end

        def call
          invoice = repository.find_by_number(invoice_number)
          return failure("Invoice not found", :not_found) if invoice.nil?

          record = Billing::Adapters::Persistence::Invoice::InvoiceRecord.find_by(number: invoice_number)
          record.update!(status: "paid", paid_at: Time.current)

          Core::Result::Success.(data: { invoice: repository.find_by_number(invoice_number) })
        end

        private

        attr_reader :invoice_number, :repository

        def failure(message, code)
          Core::Result::Failure.(message: message, code: code)
        end
      end
    end
  end
end
