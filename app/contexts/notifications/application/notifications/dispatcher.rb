module Notifications
  module Application
    module Notifications
      class Dispatcher
        def self.call(channels:)
          new(channels:).call
        end

        def initialize(channels:)
          @channels = channels
        end

        def call
          channels.each(&:call)
        end

        private

        attr_reader :channels
      end
    end
  end
end
