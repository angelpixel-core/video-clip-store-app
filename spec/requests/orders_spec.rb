require "rails_helper"

RSpec.describe "Orders requests" do
  include ActiveSupport::Testing::TimeHelpers

  before do
    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    offer_item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    OfferVariant.create!(offer:, offer_item_type:, key: "highlight_reel", name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows the order shell index" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Read PM notification", read_at: Time.current)

    get orders_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client orders")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("/orders")
    expect(response.body).to include("PM workspace")
    expect(response.body).to include("Unread notifications")
    expect(response.body).to include("Order update")
    expect(response.body).to include("Unread PM notification")
    expect(response.body).not_to include("Read PM notification")
  end

  it "creates a draft and redirects to edit" do
    get new_order_path

    draft = Project.order(:created_at).last

    expect(response).to redirect_to(edit_order_path(draft))
    expect(draft.status).to eq("draft")
  end

  it "redirects submitted orders away from the editor" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    get edit_order_path(project)

    expect(response).to redirect_to(orders_path)
  end

  it "renders the draft editor" do
    draft = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)

    get edit_order_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Back to orders")
    expect(response.body).to include("Resume draft")
    expect(response.body).to include("Review and pay")
    expect(response.body).not_to include("Project detail")
    expect(response.body).to include("Highlight Reel")
  end

  it "renders the order detail page" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Detail", raw_footage_url: "https://example.com/detail.mov", status: :pending)

    get order_path(project)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Order detail")
    expect(response.body).to include("Back to orders")
    expect(response.body).to include("Cancelar orden")
    expect(response.body).not_to include("Aceptar orden")
  end

  it "hides cancel once the payment succeeded and shows refund request when enabled" do
    allow(ENV).to receive(:fetch).with("CLIENT_REFUND_REQUEST_ENABLED", "false").and_return("true")
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Paid", raw_footage_url: "https://example.com/paid.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    get order_path(project)

    expect(response.body).not_to include("Cancelar orden")
    expect(response.body).to include("Solicitar reembolso")
  end

  it "shows reopen for cancelled client orders" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Cancelled", raw_footage_url: "https://example.com/cancelled.mov", status: :cancelled)

    get order_path(project)

    expect(response.body).to include("Retomar orden")
    expect(response.body).not_to include("Cancelar orden")
  end

  it "treats a cancel request as stale after payment succeeded" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Paid", raw_footage_url: "https://example.com/paid.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    patch cancel_order_path(project)

    expect(response).to redirect_to(orders_path)
    expect(project.reload.status).to eq("pending")
  end

  it "reopens a cancelled order back to draft" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Cancelled", raw_footage_url: "https://example.com/cancelled.mov", status: :cancelled)

    patch reopen_order_path(project)

    expect(response).to redirect_to(edit_order_path(project))
    expect(project.reload.status).to eq("draft")
  end

  it "shows the client refund request button when the feature flag is enabled" do
    allow(ENV).to receive(:fetch).with("CLIENT_REFUND_REQUEST_ENABLED", "false").and_return("true")
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Refund", raw_footage_url: "https://example.com/refund.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    get order_path(project)

    expect(response.body).to include("Solicitar reembolso")
  end

  it "accepts a paid pending order as the pm" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    patch accept_order_path(project)

    expect(response).to redirect_to(orders_path)

    project.reload
    expect(project.status).to eq("in_progress")
  end

  it "creates a refund request for a paid order" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Refund", raw_footage_url: "https://example.com/refund.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    patch request_refund_order_path(project)

    expect(response).to redirect_to(orders_path)

    project.reload
    expect(project.refund_request_pending?).to be(true)
  end

  it "approves a pending refund request as the pm" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Refund", raw_footage_url: "https://example.com/refund.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)
    Payments::Application::Commands::RequestRefund.call(payment: payment, amount_cents: payment.amount_cents)

    patch approve_refund_request_order_path(project)

    expect(response).to redirect_to(orders_path)
    expect(project.reload.refund_request_processed?).to be(true)
  end

  it "rejects a pending refund request as the pm" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Refund", raw_footage_url: "https://example.com/refund.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)
    Payments::Application::Commands::RequestRefund.call(payment: payment, amount_cents: payment.amount_cents)

    patch reject_refund_request_order_path(project)

    expect(response).to redirect_to(orders_path)
    expect(project.reload.refund_request_failed?).to be(true)
  end

  it "completes an in-progress order as the pm" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    patch complete_order_path(project)

    expect(response).to redirect_to(orders_path)

    project.reload
    expect(project.status).to eq("completed")
  end
end
