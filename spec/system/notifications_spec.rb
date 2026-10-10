require "rails_helper"

RSpec.describe "Notifications", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "shows client notifications in the navbar and as floating toasts" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    Notification.create!(project: project, client: client, kind: "project_accepted", body: "Your order Project Alpha was accepted and is now in progress.")

    visit orders_path

    expect(page).to have_css('html[data-workspace-role="client"]')
    expect(page).to have_css('#client-notifications-dropdown .client-notifications-badge', text: "1")
    expect(page).to have_css('#client-notifications-panel .client-notification-toast', text: "Project Alpha")

    find("#client-notifications-dropdown button").click

    expect(page).to have_css('#client-notifications-dropdown .dropdown-menu.show')
    expect(page).to have_css('#client-notifications-menu-list .client-notification-row', text: "Project Alpha")

    within(first("#client-notifications-panel .client-notification-toast")) do
      find("button[aria-label='Mark as read']").click
    end

    expect(page).to have_current_path(orders_path)
    expect(page).to have_no_css('#client-notifications-panel .client-notification-toast', text: "Project Alpha")
  end

  it "marks a client toast as read when the order link is clicked" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Gamma", raw_footage_url: "https://example.com/gamma.mov", status: :pending)
    notification = Notification.create!(project: project, client: client, kind: "project_accepted", body: "Your order Project Gamma was accepted and is now in progress.")

    visit orders_path

    within(first("#client-notifications-panel .client-notification-toast")) do
      click_link "Project Gamma"
    end

    expect(page).to have_current_path(order_path(project))
    expect(notification.reload.read_at).to be_present
  end

  it "receives client notifications in realtime after a pm action" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Beta", raw_footage_url: "https://example.com/beta.mov", status: :pending)
    project.video_type_selections.create!(video_type: VideoType.find_by!(name: "Highlight Reel"), quantity: 1)

    using_session(:client) do
      visit orders_path
      expect(page).to have_css('html[data-workspace-role="client"]')
      expect(page).to have_css('html[data-client-workspace-notifications-connected="true"]')
      expect(page).to have_no_css('#client-notifications-panel .client-notification-toast')
    end

    using_session(:pm) do
      visit orders_path
      find(".account-menu-trigger").click
      click_button "Switch to PM"
      click_button "Aceptar orden"
    end

    using_session(:client) do
      expect(page).to have_css('html[data-client-workspace-notifications-received="notifications_updated"]')
      visit orders_path
      expect(page).to have_css('#client-notifications-panel .client-notification-toast', text: "Project Beta", wait: 10)
      expect(page).to have_css('#client-notifications-dropdown .client-notifications-badge', text: "1", wait: 10)
    end
  end
end
