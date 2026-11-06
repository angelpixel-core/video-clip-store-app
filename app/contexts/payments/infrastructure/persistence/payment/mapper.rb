module Payments
  module Infrastructure
    module Persistence
      module Payment
        class Mapper
          def to_domain(record)
            return if record.nil?

            Payments::Domain::Aggregates::Payment.new(
              id: record.id,
              project_id: record.project_id,
              status: record.status,
              provider: record.provider,
              idempotency_key: record.idempotency_key,
              amount_cents: record.amount_cents,
              currency: record.currency,
              provider_reference: record.provider_reference,
              invoice_number: record.invoice_number,
              invoice_generated_at: record.invoice_generated_at,
              invoice_emailed_at: record.invoice_emailed_at,
              created_at: record.created_at,
              updated_at: record.updated_at
            )
          end

          def to_record(payment)
            return payment if payment.is_a?(PaymentRecord)

            record = payment.respond_to?(:id) && payment.id.present? ? PaymentRecord.find_by(id: payment.id) : nil
            record ||= PaymentRecord.new
            record.assign_attributes(
              project_id: payment.project_id,
              status: payment.status,
              provider: payment.provider,
              idempotency_key: payment.idempotency_key,
              amount_cents: payment.amount_cents,
              currency: payment.currency,
              provider_reference: payment.provider_reference,
              invoice_number: payment.invoice_number,
              invoice_generated_at: payment.invoice_generated_at,
              invoice_emailed_at: payment.invoice_emailed_at
            )
            record
          end
        end
      end
    end
  end
end
