class OrdersController < ApplicationController
  include WorkspaceProjectShell

  prepend_view_path Rails.root.join("app/views/orders")



  def simulate_payment_webhook
    return head :forbidden unless Features.payment_simulation_devtool_enabled?

    payment = @workspace_project.active_payment || @workspace_project.payments.order(created_at: :desc).first
    if payment.present?
      port = ENV.fetch("APP_PORT", 3000)
      url = ENV["WEBHOOK_URL"].presence || "http://127.0.0.1:#{port}/payments/webhooks/fake/events"
      result = Payments::Adapters::Outbound::Webhooks::WebhookSimulator.call(
        webhook_url: url,
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
