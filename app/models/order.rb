class Order < ApplicationRecord
  include AASM

  # TODO(cleanup): Drop the legacy `projects` table name once compatibility shims are retired.
  self.table_name = "projects"

  belongs_to :owner, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :owner_account_id
  belongs_to :participant, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :participant_account_id

  has_many :video_type_selections, foreign_key: :project_id, dependent: :destroy
  has_many :video_types, through: :video_type_selections
  has_many :payments, class_name: "Payments::Domain::Aggregates::Payment", foreign_key: :project_id, dependent: :destroy
  has_many :notifications, foreign_key: :project_id, dependent: :destroy
  has_many :comments, foreign_key: :project_id, dependent: :destroy

  before_validation :sync_raw_footage_metadata
  after_save :sync_order_listing!
  after_update_commit :broadcast_status_badge

  scope :for_budget_summary, lambda {
    left_outer_joins(video_type_selections: :video_type)
      .select(<<~SQL.squish)
        projects.*,
        COALESCE(SUM(video_type_selections.quantity * video_types.price_cents), 0) AS total_budget_cents
      SQL
      .group("projects.id")
  }

  aasm column: :status do
    state :draft, initial: true
    state :pending
    state :in_progress
    state :completed
    state :cancelled

    event :submit do
      transitions from: :draft, to: :pending
    end

    event :accept do
      transitions from: :pending, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end

    event :cancel do
      transitions from: :pending, to: :cancelled
    end

    event :reopen do
      transitions from: :cancelled, to: :draft
    end
  end

  validates :name, presence: true, if: :submitted?
  validates :raw_footage_url, presence: true, if: :submitted?

  def total_budget_cents
    return self[:total_budget_cents] if has_attribute?(:total_budget_cents) && self[:total_budget_cents].present?

    video_type_selections.includes(:video_type).sum do |selection|
      selection.quantity * selection.offer_variant_price_cents
    end
  end

  def offer_variants
    video_type_selections.map(&:offer_variant).compact
  end

  def submitted?
    pending? || in_progress? || completed? || cancelled?
  end

  def active_payment
    payments.active.order(created_at: :desc).first
  end

  def latest_payment
    payments.order(created_at: :desc).first
  end

  def latest_succeeded_payment
    payments.where(status: "succeeded").order(created_at: :desc).first
  end

  def payment_paid?
    latest_succeeded_payment.present?
  end

  def refund_request_pending?
    payments.joins(:refunds).merge(Payments::Domain::Entities::Refund.refund_pending).exists?
  end

  def refund_request_processing?
    payments.joins(:refunds).merge(Payments::Domain::Entities::Refund.refund_processing).exists?
  end

  def refund_request_processed?
    refund_request_processing?
  end

  def refund_request_refunded?
    payments.joins(:refunds).merge(Payments::Domain::Entities::Refund.refunded).exists?
  end

  def refund_request_failed?
    payments.joins(:refunds).merge(Payments::Domain::Entities::Refund.failed).exists?
  end

  def payment_flow_blocked?
    refund_request_pending? || refund_request_processing? || refund_request_refunded?
  end

  def can_accept_order?
    pending? && payment_paid? && !payment_flow_blocked?
  end

  def can_cancel_order?
    pending? && !payment_paid? && !payment_flow_blocked?
  end

  def can_request_refund?
    (pending? || in_progress?) && payment_paid? && !refund_request_pending? && !refund_request_processing? && !refund_request_refunded?
  end

  def can_reopen_order?
    cancelled?
  end

  def raw_footage_metadata_hash
    self[:raw_footage_metadata].presence || {}
  end

  def raw_footage_provider
    raw_footage_metadata_hash["provider"]
  end

  def raw_footage_embed_url(parent_host: nil)
    embed_url = raw_footage_metadata_hash["embed_url"]
    return embed_url unless raw_footage_provider == "twitch"

    embed_url&.gsub("{parent}", parent_host.presence || "localhost")
  end

  def raw_footage_social_preview?
    %w[instagram tiktok].include?(raw_footage_provider)
  end

  def raw_footage_thumbnail_url
    raw_footage_metadata_hash["thumbnail_url"]
  end

  def raw_footage_aspect_ratio
    raw_footage_metadata_hash["aspect_ratio"].presence || "16 / 9"
  end

  def raw_footage_watch_url
    raw_footage_metadata_hash["watch_url"].presence || raw_footage_url
  end

  def raw_footage_previewable?
    raw_footage_provider.present? && (raw_footage_embed_url.present? || raw_footage_social_preview?)
  end

  def status_badge_text
    return "Borrador" if draft?
    return "Pendiente" if pending?
    return "En progreso" if in_progress?
    return "Cancelado" if cancelled?

    "Completado"
  end

  def status_badge_class
    return "text-bg-warning" if draft?
    return "text-bg-secondary" if pending?
    return "text-bg-info" if in_progress?
    return "text-bg-danger" if cancelled?

    "text-bg-success"
  end

  def status_badge_dom_id
    ActionView::RecordIdentifier.dom_id(self, :status_badge)
  end

  def payment_badge_dom_id
    ActionView::RecordIdentifier.dom_id(self, :payment_badge)
  end

  def payment_history_html
    ApplicationController.render(
      partial: "orders/payment_history",
      locals: { payments: payments.order(created_at: :desc) }
    )
  end

  def sync_order_listing!
    order = Ordering::Adapters::Persistence::Order::OrderRecord.find_or_initialize_by(id: id)
    order.owner_account_id = owner_account_id
    order.participant_account_id = participant_account_id
    order.name = name
    order.raw_footage_url = raw_footage_url
    order.raw_footage_metadata = raw_footage_metadata_hash
    order.customer_snapshot = {
      account_id: owner.id,
      account_uid: owner.try(:uid),
      name: owner.name,
      email: owner.email,
      role: owner.role
    }
    order.uid = id.to_s
    order.status = order_status_for_listing
    order.payment_status = payment_status_for_listing
    order.production_status = production_status_for_listing
    order.delivery_status = delivery_status_for_listing
    order.created_at ||= created_at
    order.updated_at = updated_at
    order.save!

    order.order_line_records.delete_all
    video_type_selections.includes(:video_type).each do |selection|
      offer_variant = selection.offer_variant || selection.video_type
      order.order_line_records.create!(
        offering_snapshot: {
          offer_variant_id: selection.offer_variant_id || selection.video_type_id,
          offer_variant_uid: selection.video_type.try(:uid),
          name: selection.offer_variant_name,
          description: offer_variant.description,
          price_cents: selection.offer_variant_price_cents,
          output_format: offer_variant.output_format,
          offering_id: selection.video_type_id,
          offering_uid: selection.video_type.try(:uid)
        },
        quantity: selection.quantity,
        line_total_cents: selection.quantity * selection.offer_variant_price_cents,
        created_at: created_at,
        updated_at: updated_at
      )
    end

    if raw_footage_url.present?
      source_video = order.source_video_record || order.build_source_video_record
      source_video.source_url = raw_footage_url
      source_video.editing_instructions = nil
      source_video.created_at ||= created_at
      source_video.updated_at = updated_at
      source_video.save!
    else
      order.source_video_record&.destroy!
    end
  end

  private

  def sync_raw_footage_metadata
    self.raw_footage_metadata = Parsers::RawFootageUrlParser.metadata(raw_footage_url)
  end

  def order_status_for_listing
    return "draft" if draft?
    return "placed" if pending?
    return "confirmed" if in_progress?
    return "cancelled" if cancelled?

    "completed"
  end

  public

  def payment_status_for_listing
    latest_payment&.status.presence || (draft? ? "unpaid" : "pending")
  end

  def payment_badge_text
    return "Solicitud de reembolso" if refund_request_pending?
    return "Reembolso en proceso" if refund_request_processing?
    return "Reembolsado" if refund_request_refunded?
    return "Reembolso rechazado" if refund_request_failed?

    case payment_status_for_listing
    when "unpaid"
      "Sin pago"
    when "pending"
      "Pago pendiente"
    when "processing"
      "Pago en proceso"
    when "succeeded"
      "Pagado"
    when "failed"
      "Pago fallido"
    when "canceled"
      "Pago cancelado"
    when "refunded"
      "Reembolsado"
    else
      payment_status_for_listing.to_s.humanize
    end
  end

  def payment_badge_class
    return "text-bg-warning" if refund_request_pending?
    return "text-bg-info" if refund_request_processing?

    case payment_status_for_listing
    when "unpaid", "pending"
      "text-bg-secondary"
    when "processing"
      "text-bg-info"
    when "succeeded", "refunded"
      "text-bg-success"
    when "failed", "canceled"
      "text-bg-danger"
    else
      "text-bg-secondary"
    end
  end

  private

  def production_status_for_listing
    return "not_started" if draft? || pending?
    return "in_progress" if in_progress?

    "completed"
  end

  def delivery_status_for_listing
    return "not_ready" if draft? || pending?
    return "ready" if in_progress?

    "delivered"
  end

  def broadcast_status_badge
    return unless previous_changes.key?("status")

    broadcast_status_badge!
  end

  public

  def broadcast_status_badge!
    current_project = reload

    ActionCable.server.broadcast(
      "order_status_#{id}",
      {
        type: "status_updated",
        order_id: id,
        status_badge_html: ApplicationController.render(partial: "orders/status_badge", locals: { project: current_project }),
        payment_badge_html: ApplicationController.render(partial: "orders/workspace_order_payment_badge", locals: { project: current_project }),
        payment_history_html: current_project.payment_history_html
      }
    )
  end
end
