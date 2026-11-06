module Billing
  module Application
    module Commands
      class IssueInvoice
        def self.call(payment:, repository: nil, tax_gateway: nil, billing_identity: nil)
          new(payment:, repository:, tax_gateway:, billing_identity:).call
        end

        def initialize(payment:, repository: nil, tax_gateway: nil, billing_identity: nil)
          @payment = payment
          @repository = repository || Billing::Adapters::Persistence::Invoice::Repository.new
          @tax_gateway = tax_gateway || Billing::Adapters::Outbound::Integrations::TaxProviders::ARCA::TaxDocumentGateway.new
          @billing_identity = billing_identity || Billing::Domain::ValueObjects::BillingIdentity.new(name: payment.project.owner.name)
        end

        def call
          return failure("Invoice generation not allowed", :invalid_record) unless Billing::Domain::Policies::InvoiceGenerationPolicy.allow?(payment:, invoice: repository.find_by_number(invoice_number))

          invoice = Billing::Application::Handlers::InvoiceBuilder.call(payment:).with_billing_identity(billing_identity)
          tax_result = tax_gateway.issue(invoice: invoice)
          invoice = invoice.with_tax_amount(tax_result.success? ? tax_result.data.fetch(:tax_amount_cents, 0) : 0)

          persisted = repository.save(invoice)

          Core::Result::Success.(data: { invoice: persisted })
        rescue ActiveRecord::RecordInvalid => e
          failure(e.message, :invalid_record)
        end

        private

        attr_reader :payment, :repository, :tax_gateway, :billing_identity

        def invoice_number
          payment.invoice_number.presence || "INV-#{payment.id.to_s.rjust(7, '0')}"
        end

        def failure(message, code)
          Core::Result::Failure.(message: message, code: code, data: { payment_id: payment.id })
        end
      end
    end
  end
end
