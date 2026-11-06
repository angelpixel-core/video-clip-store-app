module Payments
  module Domain
    module ValueObjects
      class PaymentFailure
        attr_reader :message, :code, :details

        def initialize(message:, code:, details: {})
          @message = message.to_s
          @code = code.to_sym
          @details = details.to_h
        end

        def to_h
          { message: message, code: code, details: details }
        end

        def ==(other)
          other.respond_to?(:to_h) && to_h == other.to_h
        end
      end
    end
  end
end
