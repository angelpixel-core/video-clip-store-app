module Fulfillment
  module Application
    module Commands
      class SubmitOrder
        def self.call(order:, participant:, attributes:, selections:, repository:)
          new(order:, participant:, attributes:, selections:, repository:).call
        end

        def initialize(order:, participant:, attributes:, selections:, repository:)
          @order = order
          @participant = participant
          @attributes = attributes
          @selections = selections
          @repository = repository
        end

        def call
          return missing_selections_failure if selections.empty?

          normalized_attributes = attributes.to_h.symbolize_keys
          payment_provider = normalized_attributes.delete(:payment_provider).presence || "fake"
          payment_method_type = normalized_attributes.delete(:payment_method_type).presence || "card"
          payment_gateway = Payments::Application::Gateways.resolve(payment_provider)

          payment_result = nil
          payment = nil
          payment_failed = false

          order.class.transaction do
            order.with_lock do
              order.assign_attributes(normalized_attributes)
              order.participant = participant
              order.submit!
              repository.replace_selections(order, selections)
              order.sync_order_listing!

              submission = Ordering::Application::DTO::Submission.from_order(
                order,
                fulfillment_account: participant,
                payment_provider: payment_provider,
                payment_method_type: payment_method_type,
                metadata: { order_id: order.id }
              )

              payment_result = Ordering::Application::Commands::ProcessSubmission.call(submission: submission, payment_gateway: payment_gateway)
              if payment_result.failure?
                order.errors.add(:base, payment_result.message)
                payment_failed = true
                raise ActiveRecord::Rollback
              end

              payment = payment_result.data.fetch(:payment)
            end
          end

          return payment_failure(payment_result) if payment_failed

          Core::Result::Success.(data: { order: order, payment: payment, submission: payment_result.data.fetch(:submission) })
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          order.errors.add(:base, e.message) if order.errors.empty?
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { order_id: order.id })
        end

        private

        attr_reader :order, :participant, :attributes, :selections, :repository

        def missing_selections_failure
          order.errors.add(:base, "Add at least one video type")
          Core::Result::Failure.(message: "Add at least one video type", code: :invalid_record, data: { order_id: order.id })
        end

        def payment_failure(payment_result)
          Core::Result::Failure.(message: payment_result.message, code: payment_result.code, data: payment_result.data.merge(order_id: order.id))
        end
      end
    end
  end
end
