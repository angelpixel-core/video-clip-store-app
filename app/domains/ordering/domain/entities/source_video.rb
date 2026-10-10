module Ordering
  module Domain
    module Entities
      class SourceVideo
        attr_reader :source_url, :editing_instructions

        def initialize(source_url: nil, editing_instructions: nil)
          @source_url = build_source_url(source_url)
          @editing_instructions = build_editing_instructions(editing_instructions)
        end

        def to_h
          {
            source_url: source_url&.to_s,
            editing_instructions: editing_instructions&.to_s
          }.compact
        end

        def ==(other)
          other.respond_to?(:to_h) && other.to_h == to_h
        end

        private

        def build_source_url(value)
          return if value.nil? || value.to_s.strip.empty?

          value.is_a?(Ordering::Domain::ValueObjects::SourceUrl) ? value : Ordering::Domain::ValueObjects::SourceUrl.new(value)
        end

        def build_editing_instructions(value)
          return if value.nil? || value.to_s.strip.empty?

          value.is_a?(Ordering::Domain::ValueObjects::EditingInstructions) ? value : Ordering::Domain::ValueObjects::EditingInstructions.new(value)
        end
      end
    end
  end
end
