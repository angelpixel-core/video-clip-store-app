module Ordering
  module Adapters
    module Persistence
      module Order
        class OrderRecord < ApplicationRecord
          self.table_name = "orders"

          belongs_to :owner, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :owner_account_id
          belongs_to :participant, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :participant_account_id
          has_many :order_line_records, class_name: "Ordering::Adapters::Persistence::Order::OrderLineRecord", foreign_key: :order_id, dependent: :destroy, inverse_of: :order_record
          has_many :payments, class_name: "Payments::Domain::Aggregates::Payment", foreign_key: :project_id, primary_key: :id, dependent: :destroy
          has_one :source_video_record, class_name: "Ordering::Adapters::Persistence::Order::SourceVideoRecord", foreign_key: :order_id, dependent: :destroy, inverse_of: :order_record

          def video_type_selections
            order_line_records
          end

          def video_types
            order_line_records.map(&:video_type).compact
          end

          def offer_variants
            order_line_records.map(&:offer_variant).compact
          end

          def total_budget_cents
            self[:total_budget_cents].presence || order_line_records.sum(&:line_total_cents)
          end

          def draft?
            status == "draft"
          end

          def placed?
            status == "placed"
          end

          def confirmed?
            status == "confirmed"
          end

          def completed?
            status == "completed"
          end

          def cancelled?
            status == "cancelled"
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
            placed? && payment_paid? && !payment_flow_blocked?
          end

          def can_cancel_order?
            (placed? || confirmed?) && !payment_paid? && !payment_flow_blocked?
          end

          def can_request_refund?
            (placed? || confirmed?) && payment_paid? && !refund_request_pending? && !refund_request_processing? && !refund_request_refunded?
          end

          def pending?
            placed?
          end

          def in_progress?
            confirmed?
          end

          def delivered?
            delivery_status == "delivered"
          end

          def status_badge_text
            return "Borrador" if draft?
            return "Pendiente" if placed?
            return "En progreso" if confirmed?
            return "Cancelado" if cancelled?

            "Completado"
          end

          def status_badge_class
            return "text-bg-warning" if draft?
            return "text-bg-secondary" if placed?
            return "text-bg-info" if confirmed?
            return "text-bg-danger" if cancelled?

            "text-bg-success"
          end

          def status_badge_dom_id
            ActionView::RecordIdentifier.dom_id(self, :status_badge)
          end

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

          def raw_footage_metadata_hash
            raw_footage_metadata.presence || {}
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
        end
      end
    end
  end
end
