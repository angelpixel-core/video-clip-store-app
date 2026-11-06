module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Ingest
            WEBHOOK_SECRET = ENV.fetch("PAYMENTS_WEBHOOK_SECRET", "test-payments-webhook-secret")
            SUPPORTED_PROVIDERS = %w[fake].freeze

            def self.call(provider:, raw_body:, headers:)
              new(provider:, raw_body:, headers:).call
            end

            def initialize(provider:, raw_body:, headers:)
              @provider = provider.to_s.strip.downcase
              @raw_body = raw_body.to_s
              @headers = headers
            end

            def call
              return failure("Unknown payment provider.", :unknown_provider, provider: provider) unless supported_provider?

              payload = parse_payload
              return payload if payload.failure?

              return failure("Invalid webhook signature.", :invalid_signature, provider: provider) unless valid_signature?

              event_data = payload.data.fetch(:payload)
              event_id = event_data["id"].presence || event_data["event_id"].presence
              event_type = event_data["type"].presence || event_data["event_type"].presence

              return failure("Webhook payload is missing an event id.", :invalid_payload, provider: provider) if event_id.blank?
              return failure("Webhook payload is missing an event type.", :invalid_payload, provider: provider) if event_type.blank?

              event, created = Payments::Adapters::Persistence::Webhook::Event::Repository.upsert_received_event(
                provider: provider,
                event_id: event_id,
                event_type: event_type,
                payload: event_data,
                signature: supplied_signature
              )
              event.synchronize_payment_context!(payment_for_event(event_data))

              Payments::Adapters::Inbound::Webhooks::Event::Job.perform_later(event.id)

              success(created: created, event: event)
            rescue ActiveRecord::RecordNotUnique
              event = Payments::Adapters::Persistence::Webhook::Event::Repository.find_by_provider_and_event_id(provider: provider, provider_event_id: event_id)
              success(created: false, event: event)
            end

            private

            attr_reader :provider, :raw_body, :headers

            def supported_provider?
              SUPPORTED_PROVIDERS.include?(provider)
            end

            def parse_payload
              parsed = JSON.parse(raw_body)
              Core::Result::Success.(data: { payload: parsed })
            rescue JSON::ParserError
              failure("Webhook payload must be valid JSON.", :invalid_payload, provider: provider, raw_body: raw_body)
            end

            def valid_signature?
              supplied_signature == expected_signature
            end

            def supplied_signature
              headers["X-Payment-Signature"].presence || headers["HTTP_X_PAYMENT_SIGNATURE"].presence
            end

            def expected_signature
              OpenSSL::HMAC.hexdigest("SHA256", WEBHOOK_SECRET, raw_body)
            end

            def payment_for_event(event_data)
              payment_id = event_data["data"].to_h["payment_id"].presence
              return Payments::Domain::Repositories::PaymentRepository.find_by_id(payment_id) if payment_id.present?

              reference = event_data["data"].to_h["provider_reference"].presence || event_data["provider_reference"].presence
              return if reference.blank?

              Payments::Domain::Repositories::PaymentRepository.find_by_provider_reference(reference)
            end

            def success(created:, event:)
              Core::Result::Success.(data: { created: created, event: event })
            end

            def failure(message, code, data = {})
              Core::Result::Failure.(message: message, code: code, data: data)
            end
          end
        end
      end
    end
  end
end
