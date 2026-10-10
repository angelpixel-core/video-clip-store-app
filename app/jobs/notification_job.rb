class NotificationJob < ApplicationJob
  def perform(project_id)
    Orders::Notifications::Service.call(project: Order.find(project_id), event_type: :project_created)
  end
end
