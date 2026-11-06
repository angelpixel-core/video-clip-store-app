module Payments
  module Infrastructure
    module Persistence
      module Refund
        class Mapper
          def to_domain(record)
            return if record.nil?

            if Payments::Domain::Entities::Refund < ApplicationRecord
              record
            else
              Payments::Domain::Entities::Refund.new(
                id: record.id,
                payment_id: record.payment_id,
                payment_method_reference_id: record.payment_method_reference_id,
                amount_cents: record.amount_cents,
                status: record.status,
                provider: record.provider,
                provider_reference: record.provider_reference,
                reason: record.reason,
                metadata: record.metadata,
                created_at: record.created_at,
                updated_at: record.updated_at
              )
            end
          end

          def to_record(refund)
            return refund if refund.is_a?(RefundRecord)

            record = refund.respond_to?(:id) && refund.id.present? ? RefundRecord.find_by(id: refund.id) : nil
            record ||= RefundRecord.new
            record.assign_attributes(
              payment_id: refund.payment_id,
              payment_method_reference_id: refund.payment_method_reference_id,
              amount_cents: refund.amount_cents,
              status: refund.status,
              provider: refund.provider,
              provider_reference: refund.provider_reference,
              reason: refund.reason,
              metadata: refund.metadata
            )
            record
          end
        end
      end
    end
  end
end

