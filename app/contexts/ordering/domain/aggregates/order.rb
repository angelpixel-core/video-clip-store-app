module Ordering
  module Domain
    module Aggregates
      class Order
        attr_reader :id, :uid, :customer_snapshot, :line_items, :source_video, :status, :payment_status, :production_status, :delivery_status

        def self.draft(customer_snapshot: nil, line_items: [], order_lines: nil, source_video: nil)
          new(customer_snapshot:, line_items:, order_lines:, source_video:).tap do |order|
            order.send(:record_event, Ordering::Domain::Events::OrderDraftedEvent.new(order: order))
          end
        end

        def initialize(
          id: nil,
          uid: nil,
          customer_snapshot: nil,
          line_items: nil,
          order_lines: [],
          source_video: nil,
          status: :draft,
          payment_status: :unpaid,
          production_status: :not_started,
          delivery_status: :not_ready
        )
          @id = id && Ordering::Domain::ValueObjects::OrderID.parse(id).to_i
          @uid = build_uid(uid, @id)
          @customer_snapshot = build_customer_snapshot(customer_snapshot)
          @line_items = Array(line_items.presence || order_lines).map { |line| build_line_item(line) }
          @source_video = build_source_video(source_video)
          @status = build_order_status(status)
          @payment_status = build_payment_status(payment_status)
          @production_status = build_production_status(production_status)
          @delivery_status = build_delivery_status(delivery_status)
          @domain_events = []
        end

        def assign_identity!(id:, uid: nil)
          @id = Ordering::Domain::ValueObjects::OrderID.parse(id).to_i
          @uid = build_uid(uid, @id)
          self
        end

        def add_line(offering_snapshot:, quantity: 1)
          ensure_draft!

          line = Ordering::Domain::Entities::LineItem.new(offering_snapshot:, quantity:)
          @line_items << line
          line
        end

        def domain_events
          @domain_events.dup
        end

        def pull_domain_events
          events = domain_events
          @domain_events = []
          events
        end

        def total
          Ordering::Domain::ValueObjects::OrderTotal.from_lines(line_items)
        end

        def line_items
          @line_items
        end

        def order_lines
          line_items
        end

        def total_cents
          total.to_i
        end

        def draft?
          status.draft?
        end

        def placed?
          status.placed?
        end

        def pending?
          placed?
        end

        def confirmed?
          status.confirmed?
        end

        def payment_paid?
          payment_status.paid?
        end

        def payment_flow_blocked?
          false
        end

        def in_progress?
          confirmed?
        end

        def delivered?
          delivery_status.delivered?
        end

        def cancelled?
          status.cancelled?
        end

        def completed?
          status.completed?
        end

        def place!
          ensure_draft!
          ensure_ready_to_place!
          raise Ordering::Domain::Errors::InvalidOrderTransition, "Order cannot be placed" unless Ordering::Domain::Policies::OrderPlacementPolicy.allowed?(self)

          @status = build_order_status(:placed)
          record_event(Ordering::Domain::Events::OrderPlacedEvent.new(order: self))
          self
        end

        def confirm!
          ensure_placed!
          @status = build_order_status(:confirmed)
          record_event(Ordering::Domain::Events::OrderConfirmedEvent.new(order: self))
          self
        end

        def cancel!
          raise Ordering::Domain::Errors::InvalidOrderTransition, "Order cannot be cancelled" unless Ordering::Domain::Policies::OrderCancellationPolicy.allowed?(self)
          @status = build_order_status(:cancelled)
          record_event(Ordering::Domain::Events::OrderCancelledEvent.new(order: self))
          self
        end

        def complete!
          raise Ordering::Domain::Errors::InvalidOrderTransition, "Order cannot be completed" unless Ordering::Domain::Policies::OrderCompletionPolicy.allowed?(self)
          @status = build_order_status(:completed)
          record_event(Ordering::Domain::Events::OrderCompletedEvent.new(order: self))
          self
        end

        def mark_payment_pending!
          @payment_status = build_payment_status(:pending)
          self
        end

        def mark_payment_paid!
          @payment_status = build_payment_status(:paid)
          self
        end

        def mark_payment_failed!
          @payment_status = build_payment_status(:failed)
          record_event(Ordering::Domain::Events::OrderPaymentFailedEvent.new(order: self))
          self
        end

        def mark_payment_refunded!
          @payment_status = build_payment_status(:refunded)
          self
        end

        def start_production!
          @production_status = build_production_status(:in_progress)
          self
        end

        def queue_production!
          @production_status = build_production_status(:queued)
          self
        end

        def mark_production_review!
          @production_status = build_production_status(:review)
          self
        end

        def mark_production_completed!
          @production_status = build_production_status(:completed)
          self
        end

        def mark_delivery_ready!
          @delivery_status = build_delivery_status(:ready)
          self
        end

        def mark_delivered!
          @delivery_status = build_delivery_status(:delivered)
          self
        end

        def source_video=(value)
          @source_video = build_source_video(value)
        end

        def to_h
          {
            id: id,
            uid: uid&.to_s,
            customer_snapshot: customer_snapshot&.to_h,
            line_items: line_items.map(&:to_h),
            order_lines: line_items.map(&:to_h),
            source_video: source_video&.to_h,
            status: status.to_s,
            payment_status: payment_status.to_s,
            production_status: production_status.to_s,
            delivery_status: delivery_status.to_s,
            total_cents: total_cents
          }.compact
        end

        private

        def build_uid(value, order_id = nil)
          return value if value.is_a?(Ordering::Domain::ValueObjects::OrderNumber)
          return Ordering::Domain::ValueObjects::OrderNumber.generate(order_id:) if value.nil? && order_id.present?
          return if value.nil?

          Ordering::Domain::ValueObjects::OrderNumber.new(value)
        end

        def build_customer_snapshot(value)
          return value if value.nil? || value.is_a?(Ordering::Domain::Entities::CustomerSnapshot)

          Ordering::Domain::Entities::CustomerSnapshot.new(**value)
        end

        def build_line_item(value)
          return value if value.is_a?(Ordering::Domain::Entities::LineItem)

          Ordering::Domain::Entities::LineItem.new(**value)
        end

        def build_source_video(value)
          return value if value.nil? || value.is_a?(Ordering::Domain::Entities::SourceVideo)

          Ordering::Domain::Entities::SourceVideo.new(**value)
        end

        def build_order_status(value)
          value.is_a?(Ordering::Domain::ValueObjects::OrderStatus) ? value : Ordering::Domain::ValueObjects::OrderStatus.new(value)
        end

        def build_payment_status(value)
          value.is_a?(Ordering::Domain::ValueObjects::PaymentStatus) ? value : Ordering::Domain::ValueObjects::PaymentStatus.new(value)
        end

        def build_production_status(value)
          value.is_a?(Ordering::Domain::ValueObjects::ProductionStatus) ? value : Ordering::Domain::ValueObjects::ProductionStatus.new(value)
        end

        def build_delivery_status(value)
          value.is_a?(Ordering::Domain::ValueObjects::DeliveryStatus) ? value : Ordering::Domain::ValueObjects::DeliveryStatus.new(value)
        end

        def ensure_draft!
          raise Ordering::Domain::Errors::InvalidOrderTransition, "Order must be draft" unless draft?
        end

        def ensure_placed!
          raise Ordering::Domain::Errors::InvalidOrderTransition, "Order must be placed" unless placed?
        end

        def ensure_confirmed!
          raise Ordering::Domain::Errors::InvalidOrderTransition, "Order must be confirmed" unless confirmed?
        end

        def ensure_ready_to_place!
          raise Ordering::Domain::Errors::InvalidOrder, "Order requires a customer snapshot" if customer_snapshot.nil?
          raise Ordering::Domain::Errors::InvalidOrder, "Order requires at least one line item" if line_items.empty?
        end

        def record_event(event)
          @domain_events << event
          event
        end
      end
    end
  end
end
