module Payments
  module Domain
    module Aggregates
      class Payment
        ACTIVE_STATUSES = Payments::Domain::ValueObjects::PaymentStatus::ACTIVE_STATUSES
        TERMINAL_STATUSES = Payments::Domain::ValueObjects::PaymentStatus::TERMINAL_STATUSES
        STATUSES = Payments::Domain::ValueObjects::PaymentStatus::ALLOWED_VALUES

        attr_reader :id, :project_id, :status, :provider, :idempotency_key,
                    :amount_cents, :currency, :provider_reference,
                    :invoice_number, :invoice_generated_at, :invoice_emailed_at,
                    :created_at, :updated_at,
                    :payment_attempts, :payment_method_reference, :refunds

        def initialize(
          id: nil,
          project_id: nil,
          status: "pending",
          provider: "fake",
          idempotency_key: nil,
          amount_cents: 0,
          currency: "USD",
          provider_reference: nil,
          invoice_number: nil,
          invoice_generated_at: nil,
          invoice_emailed_at: nil,
          created_at: nil,
          updated_at: nil,
          payment_attempts: [],
          payment_method_reference: nil,
          refunds: []
        )
          @id = id
          @project_id = project_id
          @status = normalize_status(status)
          @provider = normalize_provider(provider)
          @idempotency_key = idempotency_key
          @amount_cents = amount_cents.to_i
          @currency = normalize_currency(currency)
          @provider_reference = provider_reference.presence
          @invoice_number = invoice_number
          @invoice_generated_at = invoice_generated_at
          @invoice_emailed_at = invoice_emailed_at
          @created_at = created_at
          @updated_at = updated_at
          @payment_attempts = Array(payment_attempts)
          @payment_method_reference = payment_method_reference
          @refunds = Array(refunds)
        end

        def active?
          status_object.active?
        end

        def succeeded?
          status_object.succeeded?
        end

        def invoice_generated?
          invoice_generated_at.present?
        end

        def current_payment_method_type
          payment_method_reference&.method_type_object
        end

        def status_object
          Payments::Domain::ValueObjects::PaymentStatus.new(status)
        end

        def idempotency_key_object
          Payments::Domain::ValueObjects::IdempotencyKey.new(idempotency_key) if idempotency_key.present?
        end

        def provider_reference_object
          return if provider_reference.blank?

          Payments::Domain::ValueObjects::PaymentProviderReference.new(provider_reference)
        end

        # Persistence delegation facade for seamless architectural transition
        def self.record_class
          Payments::Infrastructure::Persistence::Payment::PaymentRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, :active, :lock, :transaction, :order, :first, :last, to: :record_class
        end

        private

        def normalize_provider(val)
          val.to_s.strip.presence || "fake"
        end

        def normalize_currency(val)
          val.to_s.strip.upcase.presence || "USD"
        end

        def normalize_status(val)
          val.to_s.strip.downcase.presence || "pending"
        end
      end
    end
  end
end
