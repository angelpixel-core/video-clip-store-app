class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :workspace_for, :workspace_notifications_for, :workspace_role
  helper_method :feature_enabled?, :client_refund_request_enabled?

  private

  def workspace_resolver
    @workspace_resolver ||= Identity::Application::Services::WorkspaceResolver.new
  end

  def workspace_for(role)
    workspace_resolver.workspace_for(role)
  end

  def workspace_role
    @workspace_role ||= cookies[:workspace_role].presence_in(%w[client pm])&.to_sym || :client
  end

  def workspace_notifications_for(role)
    @workspace_notifications ||= {}
    @workspace_notifications[role.to_sym] ||= workspace_for(role).notifications.unread.includes(project: role == :pm ? :owner : :participant).order(created_at: :desc)
  end

  def feature_enabled?(key)
    ENV.fetch(key.to_s.upcase, "false") == "true"
  end

  def client_refund_request_enabled?
    feature_enabled?(:client_refund_request_enabled)
  end
end
