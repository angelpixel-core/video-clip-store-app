require "uri"

module Ordering
  module Domain
    module ValueObjects
      class SourceUrl
        def initialize(value)
          @value = value.to_s.strip
          validate!
        end

        def to_s
          value
        end

        def ==(other)
          other.to_s == value
        end

        private

        attr_reader :value

        def validate!
          uri = URI.parse(value)
          raise ArgumentError, "SourceUrl must be an http(s) URL" unless uri.is_a?(URI::HTTP) && uri.host.present?
        rescue URI::InvalidURIError
          raise ArgumentError, "SourceUrl must be an http(s) URL"
        end
      end
    end
  end
end
