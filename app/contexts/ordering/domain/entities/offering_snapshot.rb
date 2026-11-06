module Ordering
  module Domain
    module Entities
      class OfferingSnapshot
        attr_reader :offering_id, :offering_uid, :name, :description, :price_cents, :output_format

        def self.from_offer(offer)
          new(
            offering_id: offer.id,
            name: offer.name,
            description: offer.description,
            price_cents: offer.price_cents,
            output_format: offer.output_format,
            offering_uid: offer.try(:uid)
          )
        end

        def self.from_offering(offering)
          from_offer(offering)
        end

        def self.from_variant(variant)
          from_offer(variant)
        end

        def initialize(offering_id:, name:, description:, price_cents:, output_format:, offering_uid: nil)
          @offering_id = offering_id&.to_i
          @offering_uid = offering_uid&.to_s
          @name = name.to_s.strip
          @description = description.to_s.strip
          @price_cents = price_cents.to_i
          @output_format = output_format.to_s.strip
        end

        def to_h
          {
            offering_id: offering_id,
            offering_uid: offering_uid,
            name: name,
            description: description,
            price_cents: price_cents,
            output_format: output_format
          }.compact
        end

        def ==(other)
          other.respond_to?(:to_h) && other.to_h == to_h
        end
      end
    end
  end
end
