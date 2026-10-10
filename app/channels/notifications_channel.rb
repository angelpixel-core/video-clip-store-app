class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from stream_name
  end

  private

  def stream_name
    "#{role}_notifications"
  end

  def role
    params[:role].to_s == "pm" ? "pm" : "client"
  end
end
