import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  async copy(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const textToCopy = button.dataset.copyValue || this.element.dataset.copyValue
    if (!textToCopy) return

    const success = await this.copyText(textToCopy)
    if (success) {
      const originalHTML = button.innerHTML
      const originalTitle = button.getAttribute("title") || ""

      button.innerHTML = `<span class="badge text-bg-success px-1 py-0" style="font-size: 0.65rem;">✓ Copiado</span>`
      button.setAttribute("title", "Copiado al portapapeles")

      window.setTimeout(() => {
        button.innerHTML = originalHTML
        button.setAttribute("title", originalTitle)
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
      // Fallback to legacy clipboard path
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
}
