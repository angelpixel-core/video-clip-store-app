require "rails_helper"

RSpec.describe "Order status badge realtime", type: :system, js: true do
  def switch_workspace_to(mode)
    find(".account-menu-trigger").click
    click_button "Switch to #{mode}"
  end

  around do |example|
    original_client = ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"]
    original_pm = ENV["DEFAULT_PM_WORKSPACE_EMAIL"]

    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com"

    example.run
  ensure
    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = original_client
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = original_pm
  end

  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "updates the client order badge when the pm changes the status" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    using_session(:client) do
      visit orders_path

      expect(page).to have_css("##{project.status_badge_dom_id}", text: "PENDIENTE")
      expect(page).to have_css("html[data-workspace-role='client']")
      expect(page).to have_css("html[data-order-status-connected='true']")
    end

    using_session(:pm) do
      visit order_path(project)
      switch_workspace_to("PM")
      click_button "Aceptar orden"
    end

    using_session(:client) do
      expect(page).to have_css("##{project.status_badge_dom_id}", text: "EN PROGRESO")
    end
  end
end
