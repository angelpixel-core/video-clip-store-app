module Payments
  module Domain
    module Entities
      class PaymentWebhookEventAttempt
        STATUSES = %w[started succeeded failed].freeze

        attr_reader :id, :payment_webhook_event_id, :attempt_number, :status,
                    :started_at, :finished_at, :error_message, :created_at, :updated_at

        def initialize(
          id: nil,
          payment_webhook_event_id: nil,
          attempt_number: 1,
          status: "started",
          started_at: nil,
          finished_at: nil,
          error_message: nil,
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @payment_webhook_event_id = payment_webhook_event_id
          @attempt_number = attempt_number.to_i
          @status = status.to_s.presence || "started"
          @started_at = started_at || Time.current
          @finished_at = finished_at
          @error_message = error_message
          @created_at = created_at
          @updated_at = updated_at
        end

        def self.record_class
          Payments::Infrastructure::Persistence::Webhook::Event::PaymentWebhookEventAttemptRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, to: :record_class
        end
      end
    end
  end
end
