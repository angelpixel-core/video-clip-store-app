module Core
  module Services
    class Provider
      def self.call(*)
        raise NotImplementedError, "Use a concrete provider"
      end
    end
  end
end
