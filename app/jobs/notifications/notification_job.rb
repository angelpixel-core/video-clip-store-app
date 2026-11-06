module Notifications
  class NotificationJob < ApplicationJob
    queue_as :default

    def perform(order_id)
      order = Order.find_by(id: order_id)
      return unless order

      Notifications::Application::Notifications::OrderEventService.call(
        project: order,
        event_type: :project_created
      )
    end
  end
end
