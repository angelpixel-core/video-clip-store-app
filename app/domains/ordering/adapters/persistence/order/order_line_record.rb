module Ordering
  module Adapters
    module Persistence
      module Order
        class OrderLineRecord < ApplicationRecord
          self.table_name = "order_lines"

          belongs_to :order_record, class_name: "Ordering::Adapters::Persistence::Order::OrderRecord", foreign_key: :order_id, inverse_of: :order_line_records

          def offer_variant
            @offer_variant ||= begin
              variant_id = offering_snapshot.fetch("offer_variant_id", offering_snapshot.fetch("offering_id", nil))
              OfferVariant.find_by(id: variant_id) || Struct.new(:name, :description, :price_cents, :output_format).new(
                offering_snapshot["name"],
                offering_snapshot["description"],
                offering_snapshot["price_cents"],
                offering_snapshot["output_format"]
              )
            end
          end

          def video_type
            offer_variant
          end

          def offer_variant_id
            offering_snapshot["offer_variant_id"] || offering_snapshot["offering_id"]
          end

          def offer_variant_name
            offer_variant.name
          end

          def offer_variant_price_cents
            offer_variant.price_cents
          end
        end
      end
    end
  end
end
