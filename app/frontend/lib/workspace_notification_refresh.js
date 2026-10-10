let refreshPromise = null

export function shouldSuppressNotificationToast(data) {
  if (data?.kind !== "comment_created") return false

  const currentProjectId = document.querySelector("[data-order-id]")?.dataset.orderId
  return Boolean(currentProjectId && String(data.project_id) === String(currentProjectId))
}

export async function refreshWorkspaceNotifications({ panelSelector, dropdownSelector, badgeSelector, menuListSelector, tableBodySelector, force = false }) {
  if (refreshPromise) {
    if (!force) return refreshPromise

    await refreshPromise
  }

  refreshPromise = (async () => {
    const currentPanel = panelSelector ? document.querySelector(panelSelector) : null
    const currentDropdown = dropdownSelector ? document.querySelector(dropdownSelector) : null
    const currentTableBody = tableBodySelector ? document.querySelector(tableBodySelector) : null

    if (!currentPanel && !currentDropdown && !currentTableBody) return

    const response = await fetch(window.location.href, { headers: { Accept: "text/html" }, cache: "no-store" })
    if (!response.ok) return

    const html = await response.text()
    const documentFragment = new DOMParser().parseFromString(html, "text/html")

    if (currentPanel && panelSelector) {
      const nextPanel = documentFragment.querySelector(panelSelector)
      if (nextPanel) currentPanel.outerHTML = nextPanel.outerHTML
    }

    if (currentTableBody && tableBodySelector) {
      const nextTableBody = documentFragment.querySelector(tableBodySelector)
      if (nextTableBody) currentTableBody.outerHTML = nextTableBody.outerHTML
    }

    if (currentDropdown && dropdownSelector) {
      const nextDropdown = documentFragment.querySelector(dropdownSelector)
      if (!nextDropdown) return

      const currentBadge = badgeSelector ? currentDropdown.querySelector(badgeSelector) : null
      const nextBadge = badgeSelector ? nextDropdown.querySelector(badgeSelector) : null
      if (currentBadge && nextBadge) currentBadge.textContent = nextBadge.textContent

      const currentMenuList = menuListSelector ? currentDropdown.querySelector(menuListSelector) : null
      const nextMenuList = menuListSelector ? nextDropdown.querySelector(menuListSelector) : null
      if (currentMenuList && nextMenuList) currentMenuList.innerHTML = nextMenuList.innerHTML
    }
  })()

  try {
    await refreshPromise
  } finally {
    refreshPromise = null
  }
}
