module Ordering
  module Application
    module DTO
      class Submission
        attr_reader :order, :fulfillment_account, :payment_provider, :payment_method_type, :metadata

        def self.from_order(order, fulfillment_account:, payment_provider: "fake", payment_method_type: "card", metadata: {})
          new(
            order: order,
            fulfillment_account: fulfillment_account,
            payment_provider: payment_provider,
            payment_method_type: payment_method_type,
            metadata: metadata
          )
        end

        def initialize(order:, fulfillment_account:, payment_provider: "fake", payment_method_type: "card", metadata: {})
          raise ArgumentError, "order is required" if order.nil?
          raise ArgumentError, "fulfillment_account is required" if fulfillment_account.nil?

          @order = order
          @fulfillment_account = fulfillment_account
          @payment_provider = payment_provider.to_s.strip.presence || "fake"
          @payment_method_type = payment_method_type.to_s.strip.presence || "card"
          @metadata = metadata.to_h
        end

        def customer_snapshot
          return order.customer_snapshot if order.respond_to?(:customer_snapshot) && order.customer_snapshot.present?
          return Ordering::Domain::Entities::CustomerSnapshot.from_account(order.owner) if order.respond_to?(:owner) && order.owner.present?

          nil
        end

        def line_items
          return order.line_items if order.respond_to?(:line_items)
          return order.order_lines if order.respond_to?(:order_lines)
          return order.video_type_selections if order.respond_to?(:video_type_selections)

          []
        end

        def source_video
          return order.source_video if order.respond_to?(:source_video)

          nil
        end

        def total_cents
          return order.total_cents if order.respond_to?(:total_cents)
          return order.total_budget_cents if order.respond_to?(:total_budget_cents)

          0
        end

        def order_number
          return order.uid if order.respond_to?(:uid)

          nil
        end

        def to_h
          {
            order: order,
            fulfillment_account: fulfillment_account,
            payment_provider: payment_provider,
            payment_method_type: payment_method_type,
            metadata: metadata
          }
        end
      end
    end
  end
end
