module Payments
  module Domain
    module Entities
      class PaymentMethodReference
        attr_reader :id, :payment_id, :provider, :method_type, :reference,
                    :created_at, :updated_at

        def initialize(
          id: nil,
          payment_id: nil,
          provider: "fake",
          method_type: nil,
          reference: nil,
          created_at: nil,
          updated_at: nil
        )
          @id = id
          @payment_id = payment_id
          @provider = provider.to_s.presence || "fake"
          @method_type = method_type.to_s.strip.downcase
          @reference = reference
          @created_at = created_at
          @updated_at = updated_at
        end

        def method_type_object
          Payments::Domain::ValueObjects::PaymentMethodType.new(method_type)
        end

        def reference_object
          Payments::Domain::ValueObjects::PaymentProviderReference.new(reference)
        end

        def self.record_class
          Payments::Infrastructure::Persistence::Payment::PaymentMethodReferenceRecord
        end

        class << self
          delegate :find, :find_by, :find_by!, :where, :count, :create, :create!,
                   :all, to: :record_class
        end
      end
    end
  end
end
