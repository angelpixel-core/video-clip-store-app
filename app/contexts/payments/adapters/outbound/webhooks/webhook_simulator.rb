require "openssl"
require "net/http"
require "uri"

module Payments
  module Adapters
    module Outbound
      module Webhooks
        class WebhookSimulator
          def self.call(webhook_url:, provider: "fake", event_id:, type:, payment_id:, provider_reference:, amount_cents:, demo_fail_once: false, demo_fail_always: false)
            new(
              webhook_url:,
              provider:,
              event_id:,
              type:,
              payment_id:,
              provider_reference:,
              amount_cents:,
              demo_fail_once:,
              demo_fail_always:
            ).call
          end

          def initialize(webhook_url:, provider:, event_id:, type:, payment_id:, provider_reference:, amount_cents:, demo_fail_once: false, demo_fail_always: false)
            @webhook_url = webhook_url.to_s.strip
            @provider = provider.to_s.strip
            @event_id = event_id.to_s.strip
            @type = type.to_s.strip
            @payment_id = payment_id
            @provider_reference = provider_reference.to_s.strip
            @amount_cents = amount_cents
            @demo_fail_once = demo_fail_once
            @demo_fail_always = demo_fail_always
          end

          def call
            return failure("WEBHOOK_URL is required.", :missing_webhook_url) if webhook_url.blank?
            return failure("event_id is required.", :missing_event_id) if event_id.blank?
            return failure("type is required.", :missing_type) if type.blank?

            body = payload.to_json
            response = http_post(body)

            if response.code.to_i.between?(200, 299)
              Core::Result::Success.(data: response_data(response).merge(request_payload: payload))
            else
              failure(
                "Webhook simulation failed.",
                :webhook_delivery_failed,
                response: response_data(response).merge(request_payload: payload)
              )
            end
          rescue URI::InvalidURIError => e
            failure(e.message, :invalid_webhook_url, webhook_url: webhook_url)
          rescue StandardError => e
            failure(e.message, :webhook_simulation_error, webhook_url: webhook_url)
          end

          private

          attr_reader :webhook_url, :provider, :event_id, :type, :payment_id, :provider_reference, :amount_cents, :demo_fail_once, :demo_fail_always

          def payload
            {
              id: event_id,
              type: type,
              data: {
                payment_id: payment_id,
                provider_reference: provider_reference,
                amount_cents: amount_cents,
                provider: provider,
                demo_fail_once: demo_fail_once,
                demo_fail_always: demo_fail_always
              }
            }
          end

          def http_post(body)
            uri = URI.parse(webhook_url)
            request = Net::HTTP::Post.new(uri)
            request["Content-Type"] = "application/json"
            request["X-Payment-Signature"] = signature_for(body)
            request.body = body

            Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
              http.request(request)
            end
          end

          def signature_for(body)
            OpenSSL::HMAC.hexdigest("SHA256", Payments::Adapters::Inbound::Webhooks::Event::Ingest::WEBHOOK_SECRET, body)
          end

          def response_data(response)
            {
              status_code: response.code.to_i,
              body: response.body.to_s
            }
          end

          def failure(message, code, data = {})
            Core::Result::Failure.(message: message, code: code, data: data)
          end
        end
      end
    end
  end
end
