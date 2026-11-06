module Fulfillment
  module Application
    module Commands
      class ProcessOrderAction
        def self.call(order:, event:)
          new(order:, event:).call
        end

        def initialize(order:, event:)
          @order = order
          @event = event.to_sym
        end

        def call
          return unsupported_event_failure unless allowed_events.include?(event)

          order.with_lock do
            return stale_failure unless allowed_for_order?

            perform_action!

            Core::Result::Success.(data: { broadcast_refresh: broadcast_refresh? })
          end
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_transition, data: { order_id: order.id })
        end

        private

        attr_reader :order, :event

        def allowed_events
          %i[accept complete cancel reopen]
        end

        def broadcast_refresh?
          event == :accept
        end

        def perform_action!
          order.public_send("#{event}!")
        end

        def allowed_for_order?
          case event
          when :accept
            order.public_send("may_#{event}?") && order.can_accept_order?
          when :complete
            order.public_send("may_#{event}?") && !order.payment_flow_blocked?
          when :cancel
            order.public_send("may_#{event}?") && order.can_cancel_order?
          when :reopen
            order.public_send("may_#{event}?")
          else
            false
          end
        end

        def unsupported_event_failure
          Core::Result::Failure.(message: "Unsupported fulfillment action.", code: :invalid_action, data: { order_id: order.id })
        end

        def stale_failure
          Core::Result::Failure.(message: "Fulfillment action is stale.", code: :invalid_transition, data: { order_id: order.id })
        end
      end
    end
  end
end
