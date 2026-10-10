module Core
  class Result::Failure < Result
    def self.call(message:, code:, data: {})
      new(message: message, code: code, data: data)
    end

    def success?
      false
    end

    def failure?
      true
    end
  end
end
