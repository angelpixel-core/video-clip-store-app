module Notifications
  module Application
    module Notifications
      class Service
        def self.call(notification_writer:, channels:)
          new(notification_writer:, channels:).call
        end

        def initialize(notification_writer:, channels:)
          @notification_writer = notification_writer
          @channels = channels
        end

        def call
          notification_writer.call
          Dispatcher.call(channels: channels)
        end

        private

        attr_reader :notification_writer, :channels
      end
    end
  end
end
