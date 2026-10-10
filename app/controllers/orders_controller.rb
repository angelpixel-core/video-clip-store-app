class OrdersController < ApplicationController
  include WorkspaceProjectShell

  prepend_view_path Rails.root.join("app/views/orders")



  def simulate_payment_webhook
    return head :forbidden unless Rails.env.development?

    payment = @workspace_project.active_payment || @workspace_project.payments.order(created_at: :desc).first
    if payment.present?
      result = Payments::Adapters::Outbound::Webhooks::WebhookSimulator.call(
        webhook_url: "http://127.0.0.1:3000/payments/webhooks/fake/events",
        provider: "fake",
        event_id: "evt_#{SecureRandom.hex(4)}",
        type: "payment.succeeded",
        payment_id: payment.id,
        provider_reference: payment.provider_reference || "fake-abc123",
        amount_cents: payment.amount_cents
      )
      if result.success?
        flash[:notice] = "Simulated Payment Succeeded."
      else
        flash[:alert] = "Webhook simulation failed: #{result.message}"
      end
    else
      flash[:alert] = "No payment found to simulate."
    end

    redirect_to order_path(@workspace_project)
  end
end
