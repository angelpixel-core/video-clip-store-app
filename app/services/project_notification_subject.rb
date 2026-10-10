class ProjectNotificationSubject
  def self.call(project:, recipient_role:, event_type:)
    new(project:, recipient_role:, event_type:).call
  end

  def initialize(project:, recipient_role:, event_type:)
    @project = project
    @recipient_role = recipient_role.to_s
    @event_type = event_type.to_s
  end

  def call
    case recipient_role
    when "pm"
      pm_subject
    else
      client_subject
    end
  end

  private

  attr_reader :project, :recipient_role, :event_type

  def pm_subject
    case event_type
    when "project_created"
      "New order created: #{project.name}"
    when "project_accepted"
      "Order accepted: #{project.name}"
    when "project_cancelled"
      "Order cancelled: #{project.name}"
    when "project_refund_requested"
      "Refund requested: #{project.name}"
    when "project_refund_processing"
      "Refund processing: #{project.name}"
    when "project_refund_approved"
      "Refund approved: #{project.name}"
    when "project_refund_rejected"
      "Refund rejected: #{project.name}"
    when "project_reopened"
      "Order reopened: #{project.name}"
    when "project_rejected"
      "Order rejected: #{project.name}"
    when "project_completed"
      "Order completed: #{project.name}"
    else
      "Order update: #{project.name}"
    end
  end

  def client_subject
    case event_type
    when "project_created"
      "Your order #{project.name} was created"
    when "project_accepted"
      "Your order #{project.name} was accepted"
    when "project_cancelled"
      "Your order #{project.name} was cancelled"
    when "project_refund_requested"
      "A refund was requested for your order #{project.name}"
    when "project_refund_processing"
      "Your refund for #{project.name} is being processed"
    when "project_refund_approved"
      "Your refund request for #{project.name} was approved"
    when "project_refund_rejected"
      "Your refund request for #{project.name} was rejected"
    when "project_reopened"
      "Your order #{project.name} was reopened"
    when "project_rejected"
      "Your order #{project.name} needs attention"
    when "project_completed"
      "Your order #{project.name} has been completed"
    else
      "Order update for #{project.name}"
    end
  end
end
