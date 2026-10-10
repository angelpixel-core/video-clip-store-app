module Core
  class Result::Success < Result
    def self.call(data:)
      new(data: data)
    end

    def success?
      true
    end

    def failure?
      false
    end
  end
end
