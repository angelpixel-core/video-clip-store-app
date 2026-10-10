class NotificationsController < ApplicationController
  def update
    notification = find_notification
    notification.mark_as_read!

    head :no_content
  end

  private

  def find_notification
    workspace_for(:client).notifications.find_by(id: params[:id]) || workspace_for(:pm).notifications.find_by(id: params[:id]) ||
      raise(ActiveRecord::RecordNotFound)
  end
end
