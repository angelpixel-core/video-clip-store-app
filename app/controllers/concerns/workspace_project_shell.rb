module WorkspaceProjectShell
  extend ActiveSupport::Concern

  included do
    before_action :load_project, only: %i[edit update reopen]
    before_action :ensure_draft_project, only: %i[edit update]
    before_action :load_workspace_project, only: %i[accept complete cancel request_refund approve_refund_request reject_refund_request simulate_payment_webhook]
    before_action :load_offer_catalog, only: %i[new edit update]
  end

  def index
    status_order = Arel.sql("CASE status WHEN 'draft' THEN 0 WHEN 'pending' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'completed' THEN 3 ELSE 4 END")

    @projects = workspace_for(:client).projects.includes(video_type_selections: :video_type).order(status_order, created_at: :desc)

    @workspace_table_query = ::Ordering::Application::Queries::ListingQuery.new(params)
    @workspace_sort = @workspace_table_query.sort.presence || "created_at"
    @workspace_direction = @workspace_table_query.direction.presence || "desc"
    @workspace_page = @workspace_table_query.page
    @workspace_total_pages = @workspace_table_query.total_pages
    @workspace_projects = @workspace_table_query.call
  end

  def show
    @project = project_repository.find_for_show(params[:id])
    @payments = @project.payments.includes(:payment_attempts, :refunds).order(created_at: :desc)
    @comments = @project.comments.chronological.includes(:author_account)
    @comment = Comment.new
  end

  def new
    client_workspace = workspace_for(:client)
    pm_workspace = workspace_for(:pm)
    result = Fulfillment::Application::Commands::CreateDraftOrder.call(client_workspace: client_workspace, pm_workspace: pm_workspace, repository: project_repository)
    project = result.data.fetch(:order)

    redirect_to edit_order_path(project)
  end

  def edit
    @selections_json = selections_json_for(@project)
    @order_form = order_form_for(@project)
  end

  def update
    @order_form = order_form_for(@project)
    selections = parsed_selections
    finalize = finalize_submission?

    result = Fulfillment::Application::Commands::UpdateOrder.call(
      order: @project,
      participant: workspace_for(:pm),
      attributes: project_attributes,
      selections: selections,
      finalize: finalize,
      repository: project_repository
    )

    if result.success?
      finalize ? redirect_to(orders_path, notice: "Order submitted for review.") : head(:no_content)
    else
      @project.errors.add(:base, result.message) if @project.errors.empty?
      @selections_json = selections_json_for(@project)
      render :edit, status: :unprocessable_content
    end
    rescue ActiveRecord::RecordInvalid, ArgumentError, JSON::ParserError, ActionController::ParameterMissing => e
      @project.errors.add(:base, e.message) if @project.errors.empty?
      @selections_json = selections_json_for(@project)
      render :edit, status: :unprocessable_content
  end

  def reopen
    result = Orders::ActionService.call(project: @project, event: :reopen)

    if result.success?
      redirect_to edit_order_path(@project), notice: "Order reopened."
    else
      redirect_to order_path(@project), alert: "Only cancelled orders can be reopened."
    end
  end

  def accept
    process_workspace_action(
      event: :accept,
      success_notice: "Order accepted.",
      stale_alert: "The order must be paid before it can be accepted."
    )
  end

  def cancel
    process_workspace_action(
      event: :cancel,
      success_notice: "Order cancelled.",
      stale_alert: "Only unpaid pending orders can be cancelled."
    )
  end

  def request_refund
    process_workspace_action(
      event: :request_refund,
      success_notice: "Refund requested.",
      stale_alert: "Only paid orders can request a refund."
    )
  end

  def approve_refund_request
    process_workspace_action(
      event: :approve_refund_request,
      success_notice: "Refund approved.",
      stale_alert: "Only pending refund requests can be approved."
    )
  end

  def reject_refund_request
    process_workspace_action(
      event: :reject_refund_request,
      success_notice: "Refund rejected.",
      stale_alert: "Only pending refund requests can be rejected."
    )
  end

  def complete
    process_workspace_action(
      event: :complete,
      success_notice: "Order completed.",
      stale_alert: "Only in-progress orders can be completed."
    )
  end

  private

  def load_project
    @project = project_repository.find_for_edit(workspace_for(:client), params[:id])
  end

  def project_attributes
    params.require(:project).permit(:name, :raw_footage_url)
  end

  def parsed_selections
    raw = params.dig(:project, :selections_json)
    return [] if raw.blank?

    data = JSON.parse(raw, symbolize_names: true)
    data.filter_map do |selection|
      video_type_id = selection[:offer_variant_id].presence || selection[:video_type_id]
      video_type_id = video_type_id.to_i
      quantity = selection[:quantity].to_i
      next if video_type_id <= 0 || quantity <= 0

      { offer_variant_id: video_type_id, quantity: quantity }
    end
  end

  def selections_json_for(project)
    project.video_type_selections.includes(:video_type).map do |selection|
      {
        offer_variant_id: selection.offer_variant_id,
        offer_variant_name: selection.offer_variant_name,
        price_cents: selection.offer_variant_price_cents,
        quantity: selection.quantity
      }
    end.to_json
  end

  def finalize_submission?
    params.dig(:project, :finalize) == "1"
  end

  def order_form_for(project)
    Orders::OrderFormPresenter.new(project:, path: order_path(project))
  end

  def process_workspace_action(event:, success_notice:, stale_alert:)
    result = Orders::ActionService.call(project: @workspace_project, event: event)

    if result.success?
      respond_workspace_action_success(success_notice)
      Notification.broadcast_refresh_for(@workspace_project.participant) if result.data.fetch(:broadcast_refresh, false)
    else
      respond_workspace_action_stale(stale_alert)
    end
  end

  def respond_workspace_action_success(success_notice)
    if workspace_async_action_request?
      render json: workspace_row_action_payload
    else
      redirect_to orders_path, notice: success_notice
    end
  end

  def respond_workspace_action_stale(stale_alert)
    if workspace_async_action_request?
      head :conflict
    else
      redirect_to orders_path, alert: stale_alert
    end
  end

  def workspace_async_action_request?
    request.headers["X-Workspace-Async-Action"] == "1"
  end

  def load_offer_catalog
    result = Catalog::Application::Queries::ListPublicVideoTypes.call(account: workspace_for(:client))
    @offer_catalog = Catalog::OfferCatalogPresenter.new(variants: result.data.fetch(:video_types))
  end

  def ensure_draft_project
    return if @project.draft?

    redirect_to orders_path, alert: "Only draft orders can be edited."
  end

  def load_workspace_project
    @workspace_project = project_repository.find_for_workspace_action(workspace_for(:pm), params[:id]) || project_repository.find_for_show(params[:id])
  end

  def project_repository
    @project_repository ||= Fulfillment::Adapters::Persistence::Order::Repository.new
  end

  def workspace_row_action_payload
    {
      project_id: @workspace_project.id,
      status_badge_text: @workspace_project.status_badge_text,
      status_badge_class: @workspace_project.status_badge_class,
      payment_badge_text: @workspace_project.payment_badge_text,
      payment_badge_class: @workspace_project.payment_badge_class,
      action_cell_html: ApplicationController.render(partial: "orders/workspace_order_actions", locals: { project: @workspace_project })
    }
  end
end
