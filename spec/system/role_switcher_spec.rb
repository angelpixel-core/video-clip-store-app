require "rails_helper"

RSpec.describe "Role switcher", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    Project.create!(
      owner: find_workspace_account(:client),
      participant: find_workspace_account(:pm),
      name: "Project Alpha",
      raw_footage_url: "https://example.com/raw.mov",
      status: :draft
    )
    Project.create!(
      owner: find_workspace_account(:client),
      participant: find_workspace_account(:pm),
      name: "Project Beta",
      raw_footage_url: "https://example.com/beta.mov",
      status: :pending
    )
    Notification.create!(
      project: Project.find_by!(name: "Project Beta"),
      pm: find_workspace_account(:pm, email: "pm@example.com"),
      kind: "project_created",
      body: "Unread PM notification"
    )
  end

  it "persists the selected workspace mode in session storage and swaps the visible UI" do
    visit orders_path

    expect(page).to have_css('.account-menu-trigger')
    nav_controls = page.all(".ms-lg-auto > .dropdown", visible: :all)
    expect(nav_controls.map { |node| node["id"] }).to include("pm-notifications-dropdown", "client-notifications-dropdown")
    expect(nav_controls.last["class"]).to include("account-dropdown")
    expect(page).to have_content("New Order")
    expect(page).to have_content("Project Alpha")

    find(".account-menu-trigger").click
    click_button "Switch to PM"

    expect(page.evaluate_script("sessionStorage.getItem('workspace-role')")).to eq("pm")
    expect(page).to have_css('[data-role-scope="pm"]', visible: :visible)
    expect(page).to have_no_content("New Order")
    expect(page).to have_no_content("Project Alpha")

    visit new_order_path

    expect(page).to have_css('.account-menu-trigger')
    expect(page).to have_no_css('[data-role-scope="client"]', visible: :visible)

    find(".account-menu-trigger").click
    click_button "Switch to Client"

    expect(page.evaluate_script("sessionStorage.getItem('workspace-role')")).to eq("client")
    expect(page).to have_css('[data-role-scope="client"]', visible: :visible)
    expect(page).to have_no_css('[data-role-scope="pm"]', visible: :visible)
  end
end
