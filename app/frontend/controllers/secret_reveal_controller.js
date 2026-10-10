import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "revealButton", "copyButton"]

  connect() {
    this.hideValue()
  }

  toggle() {
    if (this.valueTarget.dataset.revealed === "true") {
      this.hideValue()
      return
    }

    this.showValue()
  }

  async copy() {
    const copied = await this.copyText(this.valueTarget.dataset.value)

    this.copyButtonTarget.textContent = copied ? "Copied" : "Copy failed"

    if (copied) {
      window.setTimeout(() => {
        this.copyButtonTarget.textContent = "Copy"
      }, 1500)
    }
  }

  async copyText(text) {
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(text)
        return true
      }
    } catch {
      // Fall through to the legacy copy path.
    }

    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.setAttribute("readonly", "true")
    textarea.style.position = "fixed"
    textarea.style.top = "-9999px"
    document.body.appendChild(textarea)
    textarea.select()

    const success = document.execCommand("copy")
    document.body.removeChild(textarea)
    return success
  }

  showValue() {
    this.valueTarget.dataset.revealed = "true"
    this.valueTarget.textContent = this.valueTarget.dataset.value
    this.revealButtonTarget.textContent = "Hide"
    this.revealButtonTarget.setAttribute("aria-pressed", "true")
    this.scheduleHide()
  }

  hideValue() {
    window.clearTimeout(this.hideTimer)
    this.valueTarget.dataset.revealed = "false"
    this.valueTarget.textContent = this.maskedValue()
    this.revealButtonTarget.textContent = "Show"
    this.revealButtonTarget.setAttribute("aria-pressed", "false")
  }

  maskedValue() {
    return "•".repeat(Math.min(20, this.valueTarget.dataset.value.length || 12))
  }

  scheduleHide() {
    window.clearTimeout(this.hideTimer)
    this.hideTimer = window.setTimeout(() => this.hideValue(), 3000)
  }
}
