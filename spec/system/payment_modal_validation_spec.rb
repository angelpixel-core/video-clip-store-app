require "rails_helper"

RSpec.describe "Payment modal validation", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    offer_item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    OfferVariant.create!(offer:, offer_item_type:, key: "highlight_reel", name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "formats and validates card fields" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    visit edit_order_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"
    click_button "Review and pay"

    find("#payment-name", visible: :all).set("Jane Doe")
    find("#payment-card-number", visible: :all).set("4242424242424242")
    find("#payment-card-expiry", visible: :all).set(Date.current.next_month.strftime("%m/%y"))
    click_button "Enter card security code"
    find("#payment-card-cvc", visible: :all).set("123")

    expect(page).to have_field("Card number", with: "4242 4242 4242 4242")
    expect(page).to have_field("Expiry", with: Date.current.next_month.strftime("%m/%y"))
    expect(page).to have_css("#payment-card-number.is-valid", visible: :all)
    expect(page).to have_css("#payment-card-expiry.is-valid", visible: :all)
    expect(page).to have_css("#payment-card-cvc.is-valid", visible: :all)
    expect(page).to have_css("button[data-order-form-target='finalizeButton']:not(:disabled)", visible: :all)
  end

  it "flags an expired card" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    visit edit_order_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"
    click_button "Review and pay"

    find("#payment-name", visible: :all).set("Jane Doe")
    find("#payment-card-number", visible: :all).set("4242424242424242")
    find("#payment-card-expiry", visible: :all).set(Date.current.prev_month.strftime("%m/%y"))
    find("#payment-card-expiry", visible: :all).send_keys(:tab)

    expect(page).to have_css("#payment-card-expiry.is-invalid", visible: :all)
    expect(page).to have_css("#payment-card-error", text: "Card has expired.")
    expect(page).to have_css("button[data-order-form-target='finalizeButton']:disabled", visible: :all)
  end
end
