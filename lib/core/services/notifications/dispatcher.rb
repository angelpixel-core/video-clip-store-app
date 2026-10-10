module Core
  module Services
    module Notifications
      class Dispatcher
        def self.call(...)
          new(...).call
        end

        def call
          delivery_channels.each(&:call)
        end

        private

        def delivery_channels
          raise NotImplementedError, "#{self.class} must implement #delivery_channels"
        end
      end
    end
  end
end
