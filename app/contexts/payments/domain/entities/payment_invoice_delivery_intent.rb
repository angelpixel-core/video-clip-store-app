module Payments
  module Domain
    module Entities
      class PaymentInvoiceDeliveryIntent
        STATUSES = %w[pending sent failed].freeze

        attr_reader :id, :payment_id, :status, :scheduled_at, :processed_at,
                    :attempts_count, :last_error, :created_at, :updated_at

        def initialize(
          id: nil,
          payment_id: nil,
          status: "pending",
          scheduled_at: nil,
          processed_at: nil,
          attempts_count: 0,
          last_error: nil,
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @payment_id = payment_id
          @status = status.to_s.presence || "pending"
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

        def self.record_class
          Payments::Infrastructure::Persistence::Payment::PaymentInvoiceDeliveryIntentRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, to: :record_class
        end
      end
    end
  end
end
