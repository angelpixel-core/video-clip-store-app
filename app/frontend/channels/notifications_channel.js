import { forceRefreshWorkspace } from "../lib/workspace_refresh"
import { shouldSuppressNotificationToast } from "../lib/workspace_notification_refresh"

export function subscribeToNotifications(consumer, { role }) {
  const connectedKey = `${role}WorkspaceNotificationsConnected`
  const receivedKey = `${role}WorkspaceNotificationsReceived`

  return consumer.subscriptions.create({ channel: "NotificationsChannel", role }, {
    connected() {
      document.documentElement.dataset[connectedKey] = "true"
    },

    async received(data) {
      document.documentElement.dataset[receivedKey] = data?.type || "unknown"

      if (data?.type === "notifications_updated") {
        const suppressToast = shouldSuppressNotificationToast(data)
        await forceRefreshWorkspace({ role, suppressToast })
        await new Promise((resolve) => window.setTimeout(resolve, 50))
        await forceRefreshWorkspace({ role, suppressToast })
      }
    }
  })
}

export function subscribeToClientNotifications(consumer) {
  return subscribeToNotifications(consumer, { role: "client" })
}

export function subscribeToPMNotifications(consumer) {
  return subscribeToNotifications(consumer, { role: "pm" })
}
