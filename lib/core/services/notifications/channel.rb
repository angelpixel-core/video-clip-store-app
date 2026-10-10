module Core
  module Services
    module Notifications
      class Channel
        def call
          raise NotImplementedError, "#{self.class} must implement #call"
        end
      end
    end
  end
end
