import { Controller } from "@hotwired/stimulus"

export default class OrderActionController extends Controller {
  async submit(event) {
    event.preventDefault()

    const submitter = event.submitter
    if (submitter) submitter.disabled = true

    try {
      const response = await fetch(this.element.action, {
        method: "POST",
        headers: {
          "X-Workspace-Async-Action": "1"
        },
        body: new FormData(this.element)
      })

      if (response.ok) {
        const data = await response.json()
        const currentRow = this.element.closest("tr")

        if (currentRow) {
          const paymentBadge = currentRow.querySelector("[data-order-payment-cell] .badge")
          if (paymentBadge) {
            paymentBadge.textContent = data.payment_badge_text
            paymentBadge.className = `badge ${data.payment_badge_class} text-white text-uppercase`
          }

          const statusBadge = currentRow.querySelector("[data-order-status-cell] .badge")
          if (statusBadge) {
            statusBadge.textContent = data.status_badge_text
            statusBadge.className = `badge ${data.status_badge_class} text-white text-uppercase`
          }

          const actionCell = currentRow.querySelector("[data-order-actions-cell]")
          if (actionCell) actionCell.innerHTML = data.action_cell_html || ""
        }
      }
    } catch {
      // If the async path fails, the next refresh or navigation will restore state.
    } finally {
      if (submitter && !submitter.disabled) return
      if (submitter) submitter.disabled = false
    }
  }
}
