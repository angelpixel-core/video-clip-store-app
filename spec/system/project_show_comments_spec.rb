require "rails_helper"

def switch_workspace_to(mode)
  find(".account-menu-trigger").click
  click_button "Switch to #{mode}"
end

RSpec.describe "Order show comments", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "shows a raw footage embed and allows both workspaces to comment" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(
      owner: client,
      participant: pm,
      name: "Project Alpha",
      raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      status: :in_progress
    )

    visit order_path(project)

    expect(page).to have_css("iframe[src*='youtube-nocookie.com/embed/dQw4w9WgXcQ']")
    expect(page).to have_content("No comments yet.")

    fill_in "Message", with: "Client note"
    click_button "Post comment"

    expect(page).to have_content("Comment posted.")
    expect(page).to have_css("#order-comments", text: "Client note")
    expect(page).to have_css("#order-comments .badge", text: "CLIENT")

    switch_workspace_to("PM")
    visit order_path(project)

    fill_in "Message", with: "PM reply"
    click_button "Post comment"

    expect(page).to have_css("#order-comments", text: "PM reply")
    expect(page).to have_css("#order-comments .badge", text: "PM")
  end

  it "refreshes comments and notifications across workspaces in realtime" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(
      owner: client,
      participant: pm,
      name: "Project Gamma",
      raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      status: :in_progress
    )

    using_session(:pm) do
      visit order_path(project)
      switch_workspace_to("PM")

      expect(page).to have_content("No comments yet.")
      expect(page).to have_css('#pm-notifications-dropdown .pm-notifications-badge', text: "0")
    end

    using_session(:client) do
      visit order_path(project)
      fill_in "Message", with: "Client realtime note"
      click_button "Post comment"
      expect(page).to have_content("Comment posted.")
    end

    using_session(:pm) do
      expect(page).to have_css("#order-comments", text: "Client realtime note")
      expect(page).to have_css('#pm-notifications-dropdown .pm-notifications-badge', text: "1")
      expect(page).to have_no_css('#pm-notifications-panel .pm-notification-toast', text: "Client realtime note")
    end
  end

  it "shows a raw footage preview on the client order card" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    Project.create!(
      owner: client,
      participant: pm,
      name: "Project Beta",
      raw_footage_url: "https://youtu.be/dQw4w9WgXcQ",
      status: :pending
    )

    visit orders_path

    expect(page).to have_css(".client-order-card .youtube-preview img[src*='img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg']")
    expect(page).to have_link("Project Beta", href: order_path(Project.find_by!(name: "Project Beta")))
    expect(page).to have_link("Play preview", href: order_path(Project.find_by!(name: "Project Beta")))

    click_link "Project Beta"

    expect(page).to have_current_path(order_path(Project.find_by!(name: "Project Beta")))
    expect(page).to have_content("ORDER DETAIL")
    expect(page).to have_content("Comments")
  end

  it "shows a twitch preview on the order detail page" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(
      owner: client,
      participant: pm,
      name: "Project Twitch",
      raw_footage_url: "https://www.twitch.tv/videos/2820449804",
      status: :in_progress
    )

    visit order_path(project)

    expect(page).to have_css("iframe[src*='player.twitch.tv']")
    expect(page).to have_css("iframe[src*='video=v2820449804']")
    expect(page).to have_content("Raw footage")
  end

  it "shows an instagram preview in the draft form" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    visit edit_order_path(project)

    fill_in "Name", with: "Project Instagram"
    fill_in "Raw footage URL", with: "https://www.instagram.com/p/DbBvSsRtfuB"

    expect(page).to have_css("blockquote.instagram-media")
  end

  it "shows a tiktok preview on the order detail page" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(
      owner: client,
      participant: pm,
      name: "Project TikTok",
      raw_footage_url: "https://www.tiktok.com/@demmy_061/video/7638191588631514376",
      status: :in_progress
    )

    visit order_path(project)

    expect(page).to have_css("blockquote.tiktok-embed")
    expect(page).to have_css("script[src*='tiktok.com/embed.js']", visible: :all)
  end
end
