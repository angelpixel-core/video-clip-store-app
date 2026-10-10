require "rails_helper"

RSpec.describe "Payment modal card flip", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    offer_item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    OfferVariant.create!(offer:, offer_item_type:, key: "highlight_reel", name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "flips the card when the cvc control is used and supports keyboard tab navigation" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    visit edit_order_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"

    click_button "Review and pay"

    expect(page).to have_css(".payment-card-shell", visible: :all)
    expect(page).to have_no_css(".payment-card-shell.is-flipped", visible: :all)

    # Click chip flips card to back
    click_button "Enter card security code"

    expect(page).to have_css(".payment-card-shell.is-flipped", visible: :all)
    expect(page).to have_field("CVC", with: "")

    # Click card back flips back to front
    find("[data-order-form-target='paymentCardBack']").click

    expect(page).to have_no_css(".payment-card-shell.is-flipped", visible: :all)

    # Type Visa card number -> checks brand badge detection
    find("#payment-card-number", visible: :all).set("4242424242424242")
    expect(page).to have_css("[data-order-form-target='paymentCardBrandBadge']", text: "VISA", visible: :all)

    # Tab navigation: Expiry Tab flips to CVC
    find("#payment-card-expiry", visible: :all).send_keys(:tab)
    expect(page).to have_css(".payment-card-shell.is-flipped", visible: :all)
  end
end
