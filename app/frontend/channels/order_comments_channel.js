import { insertOrderComment } from "../lib/order_comments_refresh"

export function subscribeToOrderComments(consumer) {
  const orderCommentsHost = document.querySelector("#order-comments")
  const orderId = orderCommentsHost?.closest("[data-order-id]")?.dataset.orderId

  if (!orderId || !orderCommentsHost) return null

  return consumer.subscriptions.create(
    { channel: "OrderCommentsChannel", project_id: orderId },
    {
      connected() {
        document.documentElement.dataset.orderCommentsConnected = "true"
      },

      async received(data) {
        document.documentElement.dataset.orderCommentsReceived = data?.type || "unknown"

        if (data?.type === "comments_updated") {
          insertOrderComment(data)
        }
      }
    }
  )
}
