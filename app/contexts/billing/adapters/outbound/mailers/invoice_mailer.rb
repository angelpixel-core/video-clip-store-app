module Billing
  module Adapters
    module Outbound
      module Mailers
        class InvoiceMailer < ApplicationMailer
          def invoice_ready(intent)
            @intent = intent
            @payment = intent.payment
            @project = @payment.project

            attach_invoice if @payment.invoice_document.attached?

            mail(to: @project.owner.email, subject: "Your invoice for #{@project.name}")
          end

          private

          def attach_invoice
            attachments[@payment.invoice_document.filename.to_s] = @payment.invoice_document.download
          end
        end
      end
    end
  end
end
