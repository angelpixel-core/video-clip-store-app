module Notifications
  module Application
    module Notifications
      module Channel
        class Logger
          def initialize(message, logger:)
            @message = message
            @logger = logger
          end

          def call
            logger.info(message)
          end

          private

          attr_reader :message, :logger
        end
      end
    end
  end
end
