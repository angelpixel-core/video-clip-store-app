module Billing
  module Application
    module Ports
      class TaxDocumentGateway
        def issue(_invoice:)
          raise NotImplementedError, "#{self.class} must implement #issue"
        end
      end
    end
  end
end
