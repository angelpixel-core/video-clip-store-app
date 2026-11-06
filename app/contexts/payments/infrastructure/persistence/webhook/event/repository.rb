module Payments
  module Infrastructure
    module Persistence
      module Webhook
        module Event
          class Repository
            def initialize(mapper: Mapper.new)
              @mapper = mapper
            end

            def find_by_id(id)
              record = PaymentWebhookEventRecord.find_by(id: id)
              return unless record

              mapper.to_domain(record)
            end

            def self.find_by_id(id)
              PaymentWebhookEventRecord.find_by(id: id)
            end

            def self.find_by_provider_and_event_id(provider:, provider_event_id:)
              PaymentWebhookEventRecord.find_by(provider: provider, provider_event_id: provider_event_id)
            end

            def self.upsert_received_event(provider:, event_id:, event_type:, payload:, signature:)
              event = PaymentWebhookEventRecord.find_or_initialize_by(provider: provider, provider_event_id: event_id)
              created = event.new_record?

              event.assign_attributes(
                event_type: event_type,
                payload: payload,
                signature: signature,
                status: :received,
                received_at: Time.current
              )
              event.save!

              [ event, created ]
            end

            private

            attr_reader :mapper
          end
        end
      end
    end
  end
end
