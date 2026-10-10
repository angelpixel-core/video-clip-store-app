class OrderStatusChannel < ApplicationCable::Channel
  def subscribed
    project_id = params[:project_id].presence
    reject unless project_id.present?

    stream_from "order_status_#{project_id}"
  end
end
