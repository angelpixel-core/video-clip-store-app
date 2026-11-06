module Payments
  module Infrastructure
    module Persistence
      module Payment
        class PaymentMethodReferenceRecord < ApplicationRecord
          self.table_name = "payment_method_references"

          belongs_to :payment, class_name: "Payments::Infrastructure::Persistence::Payment::PaymentRecord"

          before_validation :normalize_provider
          before_validation :normalize_method_type

          validates :payment_id, uniqueness: true
          validates :provider, presence: true
          validates :method_type, presence: true
          validates :reference, presence: true
          validate :method_type_is_supported

          def method_type_object
            Payments::Domain::ValueObjects::PaymentMethodType.new(method_type)
          end

          def reference_object
            Payments::Domain::ValueObjects::PaymentProviderReference.new(reference)
          end

          private

          def normalize_provider
            self.provider = provider.to_s.strip.presence || "fake"
          end

          def normalize_method_type
            self.method_type = method_type.to_s.strip.downcase
          end

          def method_type_is_supported
            return if Payments::Domain::ValueObjects::PaymentMethodType.valid?(method_type)

            errors.add(:method_type, "is not supported")
          end
        end
      end
    end
  end
end
