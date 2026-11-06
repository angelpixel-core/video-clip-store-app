module Billing
  module Application
    module Queries
      class FindInvoice
        def self.call(invoice_number:, repository: nil)
          new(invoice_number:, repository:).call
        end

        def initialize(invoice_number:, repository: nil)
          @invoice_number = invoice_number.to_s.strip
          @repository = repository || Billing::Adapters::Persistence::Invoice::Repository.new
        end

        def call
          invoice = repository.find_by_number(invoice_number)
          return Core::Result::Failure.(message: "Invoice not found", code: :not_found) if invoice.nil?

          Core::Result::Success.(data: { invoice: invoice })
        end

        private

        attr_reader :invoice_number, :repository
      end
    end
  end
end
