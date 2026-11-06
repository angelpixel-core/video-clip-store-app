module Core
  class Result
    attr_reader :data, :message, :code

    def initialize(data:, message: nil, code: nil)
      @data = normalize_data(data)
      @message = message
      @code = code&.to_sym
      freeze
    end

    def success?
      false
    end

    def failure?
      false
    end

    private

    def normalize_data(value)
      (value || {}).to_h
    end
  end
end
