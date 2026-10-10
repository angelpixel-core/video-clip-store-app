module Payments
  module Adapters
    module Inbound
      module Webhooks
        class PaymentWebhooksController < ApplicationController
          skip_before_action :verify_authenticity_token
          rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_unprocessable_entity

          def create
            result = Payments::Adapters::Inbound::Webhooks::Event::Ingest.(
              provider: params[:provider],
              raw_body: request.raw_post,
              headers: request.headers
            )

            if result.success?
              head(result.data.fetch(:created) ? :accepted : :ok)
            else
              head status_for(result.code)
            end
          end

          private

          def status_for(code)
            case code
            when :unknown_provider then :not_found
            when :invalid_signature then :unauthorized
            else :unprocessable_content
            end
          end

          def render_unprocessable_entity
            head :unprocessable_content
          end
        end
      end
    end
  end
end
