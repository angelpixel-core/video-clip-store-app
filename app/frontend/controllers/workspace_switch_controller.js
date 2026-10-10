import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "workspace-role"
const VALID_MODES = new Set(["client", "pm"])

export default class WorkspaceSwitchController extends Controller {
  static targets = ["switchAction", "modeLabel"]

  connect() {
    this.mode = this.loadMode()
    this.applyMode(this.mode)
  }

  select(event) {
    this.applyMode(event.currentTarget.dataset.mode)
  }

  loadMode() {
    try {
      const storedMode = window.sessionStorage.getItem(STORAGE_KEY)
      return VALID_MODES.has(storedMode) ? storedMode : "client"
    } catch {
      return "client"
    }
  }

  applyMode(mode) {
    const nextMode = VALID_MODES.has(mode) ? mode : "client"
    this.mode = nextMode
    this.element.dataset.workspaceRole = nextMode
    document.documentElement.dataset.workspaceRole = nextMode

    try {
      window.sessionStorage.setItem(STORAGE_KEY, nextMode)
    } catch {
      // Session storage can be blocked in some browsers; the UI still works.
    }

    document.cookie = `workspace_role=${nextMode}; path=/; samesite=lax`

    if (this.hasSwitchActionTarget) {
      const nextTargetMode = nextMode === "client" ? "pm" : "client"
      this.switchActionTarget.dataset.mode = nextTargetMode
      this.switchActionTarget.textContent = `Switch to ${nextTargetMode === "pm" ? "PM" : "Client"}`
    }

    if (this.hasModeLabelTarget) {
      this.modeLabelTarget.textContent = nextMode === "client" ? "Client workspace" : "PM workspace"
    }
  }
}
