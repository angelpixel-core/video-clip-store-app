module Payments
  module Domain
    module Entities
      class PaymentNotificationIntent
        STATUSES = %w[pending sent failed].freeze

        attr_reader :id, :payment_id, :project_id, :event_type, :from_status,
                    :to_status, :status, :payload, :scheduled_at, :processed_at,
                    :attempts_count, :last_error, :created_at, :updated_at

        def initialize(
          id: nil,
          payment_id: nil,
          project_id: nil,
          event_type: nil,
          from_status: nil,
          to_status: nil,
          status: "pending",
          payload: {},
          scheduled_at: nil,
          processed_at: nil,
          attempts_count: 0,
          last_error: nil,
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @payment_id = payment_id
          @project_id = project_id
          @event_type = event_type
          @from_status = from_status
          @to_status = to_status
          @status = status.to_s.presence || "pending"
          @payload = (payload || {}).to_h
          @scheduled_at = scheduled_at || Time.current
          @processed_at = processed_at
          @attempts_count = attempts_count.to_i
          @last_error = last_error
          @created_at = created_at
          @updated_at = updated_at
        end

        def pending?
          status == "pending"
        end

        def sent?
          status == "sent"
        end

        def failed?
          status == "failed"
        end

        def self.record_class
          Payments::Infrastructure::Persistence::Payment::PaymentNotificationIntentRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, to: :record_class
        end
      end
    end
  end
end
