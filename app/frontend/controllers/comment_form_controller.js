import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["authorRole", "roleLabel"]

  connect() {
    this.observer = new MutationObserver(() => this.syncRole())
    this.observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-workspace-role"],
    })
    this.syncRole()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  submit() {
    this.syncRole()
  }

  syncRole() {
    const role = document.documentElement.dataset.workspaceRole === "pm" ? "pm" : "client"

    if (this.hasAuthorRoleTarget) {
      this.authorRoleTarget.value = role
    }

    if (this.hasRoleLabelTarget) {
      this.roleLabelTarget.textContent = role === "pm" ? "PM" : "Client"
    }
  }
}
