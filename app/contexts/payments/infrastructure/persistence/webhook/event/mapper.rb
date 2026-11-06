module Payments
  module Infrastructure
    module Persistence
      module Webhook
        module Event
          class Mapper
            def to_domain(record)
              return if record.nil?

              Payments::Domain::Entities::PaymentWebhookEvent.new(
                id: record.id,
                provider: record.provider,
                provider_event_id: record.provider_event_id,
                event_type: record.event_type,
                status: record.status,
                payload: record.payload,
                signature: record.signature,
                payment_id: record.payment_id,
                project_id: record.project_id,
                received_at: record.received_at,
                processed_at: record.processed_at,
                created_at: record.created_at,
                updated_at: record.updated_at
              )
            end

            def to_record(event)
              return event if event.is_a?(PaymentWebhookEventRecord)

              record = event.respond_to?(:id) && event.id.present? ? PaymentWebhookEventRecord.find_by(id: event.id) : nil
              record ||= PaymentWebhookEventRecord.new
              record.assign_attributes(
                provider: event.provider,
                provider_event_id: event.provider_event_id,
                event_type: event.event_type,
                status: event.status,
                payload: event.payload,
                signature: event.signature,
                payment_id: event.payment_id,
                project_id: event.project_id,
                received_at: event.received_at,
                processed_at: event.processed_at
              )
              record
            end
          end
        end
      end
    end
  end
end
