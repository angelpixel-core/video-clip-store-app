module Ordering
  module Application
    module Commands
      class ProcessSubmission
        def self.call(
          submission:,
          payment_command: Payments::Application::Commands::CreatePayment,
          payment_gateway: nil,
          availability_policy: Catalog::Domain::Policies::AvailabilityPolicy,
          capacity_reserve_command: Capacity::Application::Commands::ReserveCapacity,
          capacity_commit_command: Capacity::Application::Commands::CommitCapacity,
          capacity_release_command: Capacity::Application::Commands::ReleaseCapacity
        )
          new(
            submission:,
            payment_command:,
            payment_gateway:,
            availability_policy:,
            capacity_reserve_command:,
            capacity_commit_command:,
            capacity_release_command:
          ).call
        end

        def initialize(submission:, payment_command:, payment_gateway: nil, availability_policy:, capacity_reserve_command:, capacity_commit_command:, capacity_release_command:)
          @submission = submission
          @payment_command = payment_command
          @payment_gateway = payment_gateway
          @availability_policy = availability_policy
          @capacity_reserve_command = capacity_reserve_command
          @capacity_commit_command = capacity_commit_command
          @capacity_release_command = capacity_release_command
        end

        def call
          validation_failure = validate_submission
          return validation_failure if validation_failure

          availability_failure = validate_availability
          return availability_failure if availability_failure

          reservation_result = reserve_capacity
          return capacity_failure(reservation_result) if reservation_result.failure?

          reservation = reservation_result.data.fetch(:reservation)

          payment_result = capture_or_confirm_payment
          if payment_result.failure?
            release_capacity(reservation)
            return payment_failure(payment_result)
          end

          success_checkpoint_result = success_checkpoint(payment_result.data.fetch(:payment), reservation: reservation)
          if success_checkpoint_result.failure?
            release_capacity(reservation)
            return success_checkpoint_result
          end

          success_checkpoint_result
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { submission: submission, order_id: submission.order&.id })
        end

        private

        attr_reader :submission, :payment_command, :payment_gateway, :availability_policy, :capacity_reserve_command, :capacity_commit_command, :capacity_release_command

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

        def capture_or_confirm_payment
          payment_command.(
            order: submission.order,
            provider: submission.payment_provider,
            payment_method_type: submission.payment_method_type,
            gateway: payment_gateway
          )
        end

        def reserve_capacity
          capacity_reserve_command.(
            order_id: submission.order.id,
            units: reserved_units
          )
        end

        def release_capacity(reservation)
          capacity_release_command.(order_id: reservation.order_id)
        end

        def success_checkpoint(payment, reservation:)
          return failure("Payment must be active before success checkpoint", :invalid_record) unless payment.active?

          commit_result = commit_capacity(reservation)
          return capacity_failure(commit_result) if commit_result.failure?

          enqueue_follow_up_work(payment)

          Core::Result::Success.(data: { payment: payment, order: submission.order, submission: submission, reservation: reservation })
        end

        def commit_capacity(reservation)
          capacity_commit_command.(order_id: reservation.order_id)
        end

        def enqueue_follow_up_work(payment)
          Billing::Application::Handlers::GenerateInvoiceJob.perform_later(payment.id)
          NotificationJob.perform_later(submission.order.id)
        end

        def payment_failure(payment_result)
          Core::Result::Failure.(
            message: payment_result.message,
            code: payment_result.code,
            data: payment_result.data.merge(submission: submission, order: submission.order)
          )
        end

        def failure(message, code, data = {})
          Core::Result::Failure.(message: message, code: code, data: { submission: submission, order: submission.order }.merge(data))
        end

        def capacity_failure(result)
          Core::Result::Failure.(
            message: result.message,
            code: result.code,
            data: result.data.merge(submission: submission, order: submission.order)
          )
        end

        def reserved_units
          submission.line_items.sum { |line_item| line_item.quantity.to_i }
        end

        def validate_availability
          submission.line_items.each do |line_item|
            offerable = line_item.respond_to?(:offer_variant) ? line_item.offer_variant : nil
            offerable ||= line_item.video_type if line_item.respond_to?(:video_type)

            result = availability_policy.evaluate(
              offerable,
              quantity: line_item.quantity,
              context: availability_context
            )

            return failure("Order is not available for submission", :unavailable, availability_failure_data(line_item, result)) if result.unavailable?
          end

          nil
        end

        def availability_context
          { order_id: submission.order.id }
        end

        def availability_failure_data(line_item, result)
          {
            submission: submission,
            order: submission.order,
            line_item: line_item,
            availability: result
          }
        end
      end
    end
  end
end
