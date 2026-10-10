require "securerandom"

module Domain
  module Events
    class DomainEvent
      attr_reader :event_id, :aggregate_id, :aggregate_uid, :occurred_at, :metadata, :payload

      def initialize(aggregate_id: nil, aggregate_uid: nil, payload: {}, occurred_at: Time.current, metadata: {}, event_id: SecureRandom.uuid)
        @event_id = event_id.to_s
        @aggregate_id = aggregate_id
        @aggregate_uid = aggregate_uid&.to_s
        @occurred_at = occurred_at
        @metadata = metadata.to_h
        @payload = payload.to_h
      end

      def event_type
        self.class.name
      end

      def to_h
        {
          event_id: event_id,
          aggregate_id: aggregate_id,
          aggregate_uid: aggregate_uid,
          occurred_at: occurred_at,
          metadata: metadata,
          payload: payload,
          event_type: event_type
        }.compact
      end

      def ==(other)
        other.respond_to?(:to_h) && other.to_h == to_h
      end
    end
  end
end
