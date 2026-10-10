module Orders
  module Notifications
    class Service
      def self.call(project:, event_type:)
        new(project:, event_type:).call
      end

      def initialize(project:, event_type:)
        @project = project
        @event_type = event_type.to_sym
      end

      def call
        project.notifications.unread.update_all(read_at: Time.current) if event_type == :project_accepted

        notifications_service.call(
          notification_writer: -> { create_notification! },
          channels: channels
        )
      end

      private

      attr_reader :project, :event_type

      def create_notification!
        Notification.create!(
          project: project,
          **recipient_attributes,
          kind: event_type.to_s,
          body: body_for_event
        )
      end

      def recipient_attributes
        if event_type == :project_created
          { pm: project.participant }
        elsif event_type == :project_refund_requested
          { pm: project.participant }
        elsif event_type == :project_refund_processing
          { client: project.owner }
        elsif event_type == :project_reopened
          { pm: project.participant }
        else
          { client: project.owner }
        end
      end

      def body_for_event
        case event_type
        when :project_created
          "Your order #{project.name.presence || 'Untitled order'} was submitted for review."
        when :project_accepted
          "Your order #{project.name.presence || 'Untitled order'} was accepted and is now in progress."
        when :project_cancelled
          "Your order #{project.name.presence || 'Untitled order'} was cancelled."
        when :project_refund_requested
          "A refund was requested for your order #{project.name.presence || 'Untitled order'} and is pending review."
        when :project_refund_processing
          "Your refund request for #{project.name.presence || 'Untitled order'} is being processed."
        when :project_refund_approved
          "Your refund request for #{project.name.presence || 'Untitled order'} was approved."
        when :project_refund_rejected
          "Your refund request for #{project.name.presence || 'Untitled order'} was rejected."
        when :project_reopened
          "Your order #{project.name.presence || 'Untitled order'} was reopened by the client."
        when :project_completed
          "Your order #{project.name.presence || 'Untitled order'} has been completed."
        else
          "Your order #{project.name.presence || 'Untitled order'} was updated."
        end
      end

      def channels
        [
          ::Notifications::Application::Notifications::Channel::Email.new(email_deliveries),
          ::Notifications::Application::Notifications::Channel::Logger.new(logger_message, logger: Rails.logger)
        ]
      end

      def email_deliveries
        [
          -> { ProjectNotificationMailer.public_send(event_type, project, recipient_role: :client).deliver_now },
          -> { ProjectNotificationMailer.public_send(event_type, project, recipient_role: :pm).deliver_now }
        ]
      end

      def logger_message
        "Notification for project #{project.id}: #{event_type}"
      end

      def notifications_service
        ::Notifications::Application::Notifications::Service
      end
    end
  end
end
