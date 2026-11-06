module Payments
  module Application
    module Commands
      class ReviewRefundRequest
        def self.call(payment:, approved:, reason: nil)
          new(payment:, approved:, reason:).call
        end

        def initialize(payment:, approved:, reason: nil)
          @payment = payment
          @approved = approved
          @reason = reason
        end

        def call
          refund = payment.refunds.refund_pending.order(created_at: :desc).first
          return failure("Refund request not found.", :not_found) unless refund.present?

          if approved
            result = Payments::Application::Commands::RefundPayment.call(payment:, refund:)
            return result if result.failure?

            Core::Result::Success.(data: { payment: payment, refund: result.data.fetch(:refund) })
          else
            refund.update!(status: :failed, processed_at: Time.current, reason: reason.presence || refund.reason)
            Core::Result::Success.(data: { payment: payment, refund: refund })
          end
        rescue ActiveRecord::RecordInvalid => e
          failure(e.message, :refund_update_failed)
        end

        private

        attr_reader :payment, :approved, :reason

        def failure(message, code)
          Core::Result::Failure.(message: message, code: code, data: { payment_id: payment.id })
        end
      end
    end
  end
end
