module Orders
  class ActionService
    def self.call(project:, event:)
      case event.to_sym
      when :request_refund
        return request_refund(project)
      when :approve_refund_request
        return review_refund_request(project, approved: true)
      when :reject_refund_request
        return review_refund_request(project, approved: false)
      when :reopen
        return reopen_order(project)
      end

      result = Fulfillment::Application::Commands::ProcessOrderAction.call(order: project, event: event)

      if result.success?
        project.sync_order_listing!
        Orders::Notifications::Service.call(project:, event_type: notification_event_type_for(event))
      end

      result
    end

    def self.notification_event_type_for(event)
      case event.to_sym
      when :accept
        :project_accepted
      when :cancel
        :project_cancelled
      when :reopen
        :project_reopened
      when :complete
        :project_completed
      when :request_refund
        :project_refund_requested
      when :approve_refund_request
        :project_refund_processing
      when :reject_refund_request
        :project_refund_rejected
      end
    end

    def self.request_refund(project)
      project = project.reload if project.respond_to?(:reload)
      project_id = project&.id
      return Core::Result::Failure.(message: "Refund can only be requested for active orders.", code: :invalid_transition, data: { order_id: project_id }) unless project.respond_to?(:can_request_refund?) && project.can_request_refund?

      payment = project.latest_succeeded_payment
      return Core::Result::Failure.(message: "Payment cannot be refunded.", code: :not_refundable, data: { order_id: project_id }) unless payment.present?

      result = Payments::Application::Commands::RequestRefund.call(
        payment: payment,
        amount_cents: payment.amount_cents,
        reason: "requested_by_operator"
      )

      return result if result.failure?

      project.sync_order_listing!
      Orders::Notifications::Service.call(project:, event_type: :project_refund_requested)

      Core::Result::Success.(data: { payment: payment, refund: result.data.fetch(:refund), broadcast_refresh: false })
    end

    def self.review_refund_request(project, approved:)
      payment = project.latest_succeeded_payment
      return Core::Result::Failure.(message: "Refund request not found.", code: :not_found, data: { order_id: project&.id }) unless payment.present?

      result = Payments::Application::Commands::ReviewRefundRequest.call(
        payment: payment,
        approved: approved,
        reason: approved ? "approved_by_operator" : "rejected_by_operator"
      )

      return result if result.failure?

      project.sync_order_listing!
      Orders::Notifications::Service.call(project:, event_type: approved ? :project_refund_processing : :project_refund_rejected)

      Core::Result::Success.(data: { payment: payment, refund: result.data.fetch(:refund), broadcast_refresh: false })
    end

    def self.reopen_order(project)
      project = project.reload if project.respond_to?(:reload)
      return Core::Result::Failure.(message: "Only cancelled orders can be reopened.", code: :invalid_transition, data: { order_id: project&.id }) unless project.respond_to?(:can_reopen_order?) && project.can_reopen_order?

      result = Fulfillment::Application::Commands::ProcessOrderAction.call(order: project, event: :reopen)
      return result if result.failure?

      project.sync_order_listing!
      Orders::Notifications::Service.call(project:, event_type: :project_reopened)

      Core::Result::Success.(data: { order: project, broadcast_refresh: false })
    end
  end
end
