module Billing
  module Adapters
    module Persistence
      module Invoice
        class Mapper
          def to_domain(record)
            return if record.nil?

            Billing::Domain::Aggregates::Invoice.new(
              id: record.id,
              payment_id: record.payment_id,
              number: record.number,
              order_id: record.order_id,
              order_name: record.order_name,
              recipient_name: record.recipient_name,
              recipient_email: record.recipient_email,
              lines: Array(record.lines_json).map { |line| Billing::Domain::Entities::InvoiceLine.new(**line.symbolize_keys) },
              content: record.content,
              content_type: record.content_type,
              issued_at: record.issued_at,
              status: record.status,
              tax_amount_cents: record.tax_amount_cents,
              billing_identity: billing_identity_from(record.billing_identity_json)
            )
          end

          def to_record(invoice)
            record = InvoiceRecord.find_or_initialize_by(number: invoice.number)
            record.payment_id = invoice.payment_id
            record.order_id = invoice.order_id
            record.order_name = invoice.order_name
            record.recipient_name = invoice.recipient_name
            record.recipient_email = invoice.recipient_email
            record.lines_json = invoice.lines.map(&:to_h)
            record.content = invoice.content
            record.content_type = invoice.content_type
            record.issued_at = invoice.issued_at
            record.status = invoice.status
            record.tax_amount_cents = invoice.tax_amount_cents
            record.total_cents = invoice.total_cents
            record.billing_identity_json = invoice.billing_identity&.to_h
            record
          end

          private

          def billing_identity_from(json)
            return if json.blank?

            Billing::Domain::ValueObjects::BillingIdentity.new(**json.deep_symbolize_keys)
          end
        end
      end
    end
  end
end
