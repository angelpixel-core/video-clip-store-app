module Ordering
  module Adapters
    module Persistence
      module Order
        class Mapper
          def to_domain(record)
            Ordering::Domain::Aggregates::Order.new(
              id: record.id,
              uid: record.uid,
              customer_snapshot: record.customer_snapshot,
              line_items: record.order_line_records.map do |line_record|
                {
                  offering_snapshot: line_record.offering_snapshot,
                  quantity: line_record.quantity
                }
              end,
              source_video: record.source_video_record && {
                source_url: record.source_video_record.source_url,
                editing_instructions: record.source_video_record.editing_instructions
              },
              status: record.status,
              payment_status: record.payment_status,
              production_status: record.production_status,
              delivery_status: record.delivery_status
            )
          end

          def write(order, record)
            record.uid = order.uid&.to_s
            record.customer_snapshot = order.customer_snapshot&.to_h
            record.status = order.status.to_s
            record.payment_status = order.payment_status.to_s
            record.production_status = order.production_status.to_s
            record.delivery_status = order.delivery_status.to_s
            record
          end

          def sync_children!(order, record)
            sync_order_lines!(order, record)
            sync_source_video!(order, record)
          end

          private

          def sync_order_lines!(order, record)
            record.order_line_records.destroy_all
            order.line_items.each do |line|
              record.order_line_records.create!(
                offering_snapshot: line.offering_snapshot.to_h,
                quantity: line.quantity,
                line_total_cents: line.line_total_cents
              )
            end
          end

          def sync_source_video!(order, record)
            record.source_video_record&.destroy!
            return if order.source_video.nil?

            record.create_source_video_record!(
              source_url: order.source_video.source_url&.to_s,
              editing_instructions: order.source_video.editing_instructions&.to_s
            )
          end
        end
      end
    end
  end
end
