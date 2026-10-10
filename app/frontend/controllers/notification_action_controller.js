import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async open(event) {
    event.preventDefault()

    const link = event.currentTarget
    const readUrl = link.dataset.notificationReadUrl
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      if (readUrl) {
        await fetch(readUrl, {
          method: "PATCH",
          headers: {
            Accept: "text/html",
            "X-CSRF-Token": token || "",
          },
        })
      }
    } finally {
      window.location.assign(link.href)
    }
  }

  async submit(event) {
    event.preventDefault()

    const form = event.currentTarget
    const item = form.closest("[data-notification-item]")
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(form.action, {
        method: "POST",
        headers: {
          Accept: "text/html",
          "X-CSRF-Token": token || "",
        },
        body: new FormData(form),
      })

      if (!response.ok) return

      if (!item) return

      item.classList.add("is-dismissing")
      window.setTimeout(() => item.remove(), 180)
    } catch {
      // If the request fails, leave the notification in place so it can be retried.
    }
  }
}
