module Payments
  module Domain
    module Repositories
      class PaymentRepository
        def self.find_by_id(id)
          Payments::Domain::Aggregates::Payment.find_by(id: id.to_s)
        end

        def self.find_by_provider_reference(provider_reference)
          Payments::Domain::Aggregates::Payment.find_by(provider_reference: provider_reference.to_s)
        end

        def self.find_active_by_project(project)
          project.payments.active.order(created_at: :desc).first
        end
      end
    end
  end
end
