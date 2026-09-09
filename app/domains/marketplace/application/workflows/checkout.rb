module Marketplace
  module Application
    module Workflows
      class Checkout
        def self.call(submission:, payment_port:, payment_gateway: nil, availability_port:, capacity_port:, invoicing_port:, notification_port:)
          new(
            submission:,
            payment_port:,
            payment_gateway:,
            availability_port:,
            capacity_port:,
            invoicing_port:,
            notification_port:
          ).call
        end

        def initialize(submission:, payment_port:, payment_gateway: nil, availability_port:, capacity_port:, invoicing_port:, notification_port:)
          @submission = submission
          @payment_port = payment_port
          @payment_gateway = payment_gateway
          @availability_port = availability_port
          @capacity_port = capacity_port
          @invoicing_port = invoicing_port
          @notification_port = notification_port
        end

        def call
          validation_failure = validate_submission
          return validation_failure if validation_failure

          availability_failure = validate_availability
          return availability_failure if availability_failure

          reservation_result = capacity_port.reserve(order_id: submission.order.id, units: reserved_units)
          return capacity_failure(reservation_result) if reservation_result.failure?

          reservation = reservation_result.data.fetch(:reservation)
          payment_result = payment_port.call(
            order: submission.order,
            provider: submission.payment_provider,
            payment_method_type: submission.payment_method_type,
            gateway: payment_gateway
          )

          if payment_result.failure?
            capacity_port.release(reservation: reservation)
            return payment_failure(payment_result)
          end

          payment = payment_result.data.fetch(:payment)
          return checkpoint_failure(reservation) unless payment.active?

          commit_result = capacity_port.commit(reservation: reservation)
          if commit_result.failure?
            capacity_port.release(reservation: reservation)
            return capacity_failure(commit_result)
          end

          invoicing_port.call(payment: payment)
          notification_port.call(order: submission.order)

          Core::Result::Success.(data: { payment: payment, order: submission.order, submission: submission, reservation: reservation })
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { submission: submission, order_id: submission.order&.id })
        end

        private

        attr_reader :submission, :payment_port, :payment_gateway, :availability_port, :capacity_port, :invoicing_port, :notification_port

        def validate_submission
          return failure("Submission requires an order", :invalid_record) if submission.order.nil?
          return failure("Submission requires a fulfillment account", :invalid_record) if submission.fulfillment_account.nil?
          return failure("Submission requires at least one line item", :invalid_record) if submission.line_items.empty?
          return failure("Order is not ready for submission", :invalid_record) if submission_ready_state? == false

          nil
        end

        def submission_ready_state?
          order = submission.order
          return order.submitted? if order.respond_to?(:submitted?)
          return order.placed? if order.respond_to?(:placed?)
          return order.confirmed? if order.respond_to?(:confirmed?)

          true
        end

        def validate_availability
          submission.line_items.each do |line_item|
            offerable = line_item.respond_to?(:offer_variant) ? line_item.offer_variant : nil
            offerable ||= line_item.video_type if line_item.respond_to?(:video_type)
            result = availability_port.evaluate(offerable, quantity: line_item.quantity, context: { order_id: submission.order.id })
            return failure("Order is not available for submission", :unavailable, { line_item: line_item, availability: result }) if result.unavailable?
          end

          nil
        end

        def checkpoint_failure(reservation)
          capacity_port.release(reservation: reservation)
          failure("Payment must be active before success checkpoint", :invalid_record)
        end

        def payment_failure(result)
          Core::Result::Failure.(message: result.message, code: result.code, data: result.data.merge(submission: submission, order: submission.order))
        end

        def capacity_failure(result)
          Core::Result::Failure.(message: result.message, code: result.code, data: result.data.merge(submission: submission, order: submission.order))
        end

        def failure(message, code, data = {})
          Core::Result::Failure.(message:, code:, data: { submission: submission, order: submission.order }.merge(data))
        end

        def reserved_units
          submission.line_items.sum { |line_item| line_item.quantity.to_i }
        end
      end
    end
  end
end
