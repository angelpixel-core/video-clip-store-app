module Billing
  module Adapters
    module Outbound
      module Integrations
        module TaxProviders
          module ARCA
            class TaxDocumentGateway < Billing::Application::Ports::TaxDocumentGateway
              def issue(invoice:)
                tax_amount_cents = Billing::Domain::Policies::TaxCalculationPolicy.call(
                  base_amount_cents: invoice.total_cents,
                  billing_identity: invoice.respond_to?(:billing_identity) ? invoice.billing_identity : nil
                )

                Core::Result::Success.(
                  data: {
                    provider: "ARCA",
                    tax_amount_cents: tax_amount_cents,
                    document_number: "ARCA-#{invoice.number}"
                  }
                )
              end
            end
          end
        end
      end
    end
  end
end
