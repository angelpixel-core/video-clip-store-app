require "rails_helper"

RSpec.describe "Orders requests (detailed)" do
  include ActiveSupport::Testing::TimeHelpers

  before do
    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows the client order index" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    Project.create!(owner: client, participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Read PM notification", read_at: Time.current)

    get orders_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client orders")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("Borrador")
    expect(response.body).to include("Reanudar")
    expect(response.body).to include("PM workspace")
    expect(response.body).to include("Unread notifications")
    expect(response.body).to include("Unread PM notification")
    expect(response.body).not_to include("Read PM notification")
  end

  it "keeps the customer-facing order flow intact during the order rename" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    get orders_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client orders")
    expect(response.body).to include("New Order")

    get new_order_path
    expect(response).to redirect_to(edit_order_path(Project.order(:created_at).last))

    get edit_order_path(project)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Resume draft")

    get order_path(project)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Order detail")
    expect(response.body).to include("Project Alpha")
  end

  it "shows the pm order table sorted by creation date" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    highlight_reel = VideoType.find_by!(name: "Highlight Reel")
    social_cut = VideoType.find_by!(name: "Social Cut")
    cookies[:workspace_role] = "pm"

    travel_to 2.days.ago do
      older_project = Project.create!(owner: client, participant: pm, name: "Older Project", raw_footage_url: "https://example.com/older.mov", status: :pending)
      older_project.video_type_selections.create!(video_type: highlight_reel, quantity: 1)
    end

    travel_to 1.day.ago do
      newer_project = Project.create!(owner: client, participant: pm, name: "Newer Project", raw_footage_url: "https://example.com/newer.mov", status: :in_progress)
      newer_project.video_type_selections.create!(video_type: social_cut, quantity: 2)
    end

    get orders_path

    workspace_table_body = response.body[/<tbody id="workspace-orders-table-body">.*?<\/tbody>/m]

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ID")
    expect(response.body).to include("Created at")
    expect(response.body).to include("Total budget")
    expect(response.body).to include("$250.00")
    expect(response.body).to include("$300.00")
    expect(workspace_table_body.index("Newer Project")).to be < workspace_table_body.index("Older Project")
  ensure
    travel_back
  end

  it "shows pm table sort links" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    cookies[:workspace_role] = "pm"

    Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/alpha.mov", status: :pending)

    get orders_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ID")
    expect(response.body).to include("Created at")
    expect(response.body).to include("Total budget")
    expect(response.body).to include("table-sort-link is-active")
    expect(response.body).to include("sort=id")
    expect(response.body).to include("direction=desc")
    expect(response.body).to include("sort=created_at")
    expect(response.body).to include("sort=total_budget")
  end

  it "keeps the page when generating pm table sort links" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    cookies[:workspace_role] = "pm"

    11.times do |index|
      Project.create!(owner: client, participant: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
    end

    get orders_path(page: 2)

    expect(response.body).to include("page=2")
    expect(response.body).to include("sort=id")
    expect(response.body).to include("sort=created_at")
    expect(response.body).to include("sort=total_budget")
    expect(response.body).to include("direction=desc")
  end

  it "shows pm pagination links and loads the second page" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    cookies[:workspace_role] = "pm"

    11.times do |index|
      travel_to (10 - index).minutes.ago do
        Project.create!(owner: client, participant: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
      end
    end

    get orders_path(page: 2)

    workspace_table_body = response.body[/<tbody id="workspace-orders-table-body">.*?<\/tbody>/m]

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Workspace orders pagination")
    expect(response.body).to include("Prev")
    expect(response.body).to include("1")
    expect(response.body).to include("2")
    expect(response.body).to include("Next")
    expect(workspace_table_body).to include("Project 1")
    expect(workspace_table_body).not_to include("Project 11")
  ensure
    travel_back
  end

  it "shows a pm order detail page" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    get order_path(project)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Order detail")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("Aceptar orden")
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
    offer = Offer.create!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    offer_item_type = OfferItemType.create!(key: "video_type", name: "Video Type", description: "Selectable video editing component", input_kind: "selection")
    OfferVariant.create!(offer:, offer_item_type:, key: "highlight_reel", name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")

    draft = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)

    get edit_order_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Resume draft")
    expect(response.body).to include("Video Editing")
    expect(response.body).to include("Highlight Reel")
    expect(response.body).to include('name="project[name]"')
    expect(response.body).to include('name="project[raw_footage_url]"')
    expect(response.body).to include('name="project[selections_json]"')
    expect(response.body).to include('name="project[finalize]"')
  end

  it "autosaves a draft and keeps it in draft status" do
    draft = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)

    patch order_path(draft), params: {
      project: {
        name: "Project Beta",
        raw_footage_url: "https://example.com/beta.mov",
        finalize: "0",
        selections_json: [
          { video_type_id: VideoType.find_by!(name: "Highlight Reel").id, quantity: 2 },
          { video_type_id: VideoType.find_by!(name: "Social Cut").id, quantity: 1 }
        ].to_json
      }
    }

    expect(response).to have_http_status(:no_content)

    draft.reload

    expect(draft.status).to eq("draft")
    expect(draft.name).to eq("Project Beta")
    expect(draft.video_type_selections.count).to eq(2)
  end

  it "finalizes a draft with selections" do
    draft = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)

    expect do
      patch order_path(draft), params: {
        project: {
          name: "Project Gamma",
          raw_footage_url: "https://example.com/gamma.mov",
          finalize: "1",
          selections_json: [
            { video_type_id: VideoType.find_by!(name: "Highlight Reel").id, quantity: 2 }
          ].to_json
        }
      }
    end.to have_enqueued_job(NotificationJob).with(draft.id)

    expect(response).to redirect_to(orders_path)

    draft.reload
    expect(draft.status).to eq("pending")
    expect(draft.participant.email).to eq("pm@example.com")
    expect(draft.video_type_selections.count).to eq(1)
    expect(draft.payments.count).to eq(1)
    expect(draft.active_payment).to be_present
    expect(draft.active_payment.amount_cents).to eq(50_000)
    expect(draft.active_payment.payment_attempts.count).to eq(1)
  end

  it "accepts a pending order as the pm" do
    cookies[:workspace_role] = "pm"
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

  it "accepts a pending order asynchronously" do
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Async", raw_footage_url: "https://example.com/async.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    patch accept_order_path(project), headers: { "X-Workspace-Async-Action" => "1" }

    expect(response).to have_http_status(:ok)
    payload = JSON.parse(response.body)

    expect(payload["project_id"]).to eq(project.id)
    expect(payload["status_badge_text"]).to eq("En progreso")
    expect(payload["status_badge_class"]).to eq("text-bg-info")
    expect(payload["action_cell_html"]).to include("Marcar como completado")

    project.reload
    expect(project.status).to eq("in_progress")
  end

  it "rejects stale asynchronous pm row actions" do
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Async Stale", raw_footage_url: "https://example.com/stale.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    patch accept_order_path(project), headers: { "X-Workspace-Async-Action" => "1" }
    patch accept_order_path(project), headers: { "X-Workspace-Async-Action" => "1" }

    expect(response).to have_http_status(:conflict)
    expect(project.reload.status).to eq("in_progress")
  end

  it "completes an in-progress order as the pm" do
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    patch complete_order_path(project)

    expect(response).to redirect_to(orders_path)

    project.reload
    expect(project.status).to eq("completed")
  end

  it "creates a client notification when a pending order is accepted" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: client, participant: pm, name: "Project Client Update", raw_footage_url: "https://example.com/client-update.mov", status: :pending)
    video_type = VideoType.find_by!(name: "Highlight Reel")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)
    payment = Payments::Application::Commands::CreatePayment.call(project: project).data.fetch(:payment)
    payment.update!(status: :succeeded)

    expect do
      patch accept_order_path(project)
    end.to change(Notification, :count).by(1)

    notification = Notification.order(:created_at).last

    expect(notification.client).to eq(client)
    expect(notification.pm).to be_nil
    expect(notification.kind).to eq("project_accepted")
    expect(notification.body).to include("accepted and is now in progress")
  end

  it "creates a client notification when an in-progress order is completed" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: client, participant: pm, name: "Project Client Complete", raw_footage_url: "https://example.com/client-complete.mov", status: :in_progress)

    expect do
      patch complete_order_path(project)
    end.to change(Notification, :count).by(1)

    notification = Notification.order(:created_at).last

    expect(notification.client).to eq(client)
    expect(notification.pm).to be_nil
    expect(notification.kind).to eq("project_completed")
    expect(notification.body).to include("has been completed")
  end

  it "completes an in-progress order asynchronously" do
    cookies[:workspace_role] = "pm"
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Async Complete", raw_footage_url: "https://example.com/complete.mov", status: :in_progress)

    patch complete_order_path(project), headers: { "X-Workspace-Async-Action" => "1" }

    expect(response).to have_http_status(:ok)
    payload = JSON.parse(response.body)

    expect(payload["project_id"]).to eq(project.id)
    expect(payload["status_badge_text"]).to eq("Completado")
    expect(payload["status_badge_class"]).to eq("text-bg-success")
    expect(payload["action_cell_html"]).to include("d-inline-flex flex-wrap gap-2 justify-content-end")

    project.reload
    expect(project.status).to eq("completed")
  end

  it "rejects finalization without selections" do
    draft = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)

    patch order_path(draft), params: {
      project: {
        name: "Project Gamma",
        raw_footage_url: "https://example.com/gamma.mov",
        finalize: "1",
        selections_json: "[]"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Add at least one video type")
  end
end
