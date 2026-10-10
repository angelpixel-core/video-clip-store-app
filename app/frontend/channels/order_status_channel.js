export function subscribeToOrderStatus(consumer) {
  const orderContainers = document.querySelectorAll("[data-order-id]")

  if (!orderContainers.length) return null

  return Array.from(orderContainers).map((orderContainer) => {
    const orderId = orderContainer?.dataset.orderId

    if (!orderId) return null

    return consumer.subscriptions.create(
      { channel: "OrderStatusChannel", project_id: orderId },
      {
        connected() {
          document.documentElement.dataset.orderStatusConnected = "true"
        },

        received(data) {
          document.documentElement.dataset.orderStatusReceived = data?.type || "unknown"

          if (data?.type === "status_updated" && data.order_id?.toString() === orderId) {
            const statusCell = orderContainer.querySelector("[data-order-status-cell]")
            const statusBadge = orderContainer.querySelector("[id^='status_badge_']")
            const paymentCell = orderContainer.querySelector("[data-order-payment-cell]")
            const paymentHistory = orderContainer.querySelector("[data-order-payment-history]")

            if (statusCell && data.status_badge_html) {
              statusCell.innerHTML = data.status_badge_html
            } else if (statusBadge && data.status_badge_html) {
              statusBadge.innerHTML = data.status_badge_html
            }

            if (paymentCell && data.payment_badge_html) {
              paymentCell.innerHTML = data.payment_badge_html
            }

            if (paymentHistory && data.payment_history_html) {
              paymentHistory.innerHTML = data.payment_history_html
            }
          }
        }
      }
    )
  })
}
