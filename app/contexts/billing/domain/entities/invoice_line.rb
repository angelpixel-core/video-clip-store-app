module Billing
  module Domain
    module Entities
      class InvoiceLine
        attr_reader :description, :quantity, :unit_amount_cents, :line_total_cents

        def self.from_selection(selection)
          new(
            description: selection.offer_variant_name,
            quantity: selection.quantity,
            unit_amount_cents: selection.offer_variant_price_cents
          )
        end

        def initialize(description:, quantity:, unit_amount_cents:, line_total_cents: nil)
          @description = description.to_s.strip
          @quantity = quantity.to_i
          @unit_amount_cents = unit_amount_cents.to_i
          @line_total_cents = line_total_cents.present? ? line_total_cents.to_i : @quantity * @unit_amount_cents
        end

        def to_h
          {
            description: description,
            quantity: quantity,
            unit_amount_cents: unit_amount_cents,
            line_total_cents: line_total_cents
          }
        end
      end
    end
  end
end
