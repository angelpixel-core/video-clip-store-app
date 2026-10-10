module Ordering
  module Domain
    module Events
      class OrderEvent < ::Domain::Events::DomainEvent
        attr_reader :order

        def initialize(order:, payload: {}, occurred_at: Time.current, metadata: {}, event_id: SecureRandom.uuid)
          @order = order
          super(
            aggregate_id: order&.id,
            aggregate_uid: order&.uid,
            payload: order_payload.merge(payload.to_h),
            occurred_at: occurred_at,
            metadata: metadata,
            event_id: event_id
          )
        end

        def order_id
          order&.id
        end

        def order_uid
          order&.uid&.to_s
        end

        def order_number
          order&.uid&.to_s
        end

        private

        def order_payload
          return {} unless order

          order.to_h
        end
      end
    end
  end
end
