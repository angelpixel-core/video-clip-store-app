import { refreshWorkspaceNotifications } from "./workspace_notification_refresh"

export function refreshWorkspace({ role, suppressToast = false } = {}) {
  const config = role === "pm"
    ? {
        panelSelector: suppressToast ? null : "#pm-notifications-panel",
        dropdownSelector: "#pm-notifications-dropdown",
        badgeSelector: ".pm-notifications-badge",
        menuListSelector: "#pm-notifications-menu-list",
        tableBodySelector: "#workspace-orders-table-body"
      }
    : {
        panelSelector: suppressToast ? null : "#client-notifications-panel",
        dropdownSelector: "#client-notifications-dropdown",
        badgeSelector: ".client-notifications-badge",
        menuListSelector: "#client-notifications-menu-list"
      }

  return refreshWorkspaceNotifications(config)
}

export function forceRefreshWorkspace({ role, suppressToast = false } = {}) {
  return refreshWorkspace({ role, suppressToast, force: true })
}
