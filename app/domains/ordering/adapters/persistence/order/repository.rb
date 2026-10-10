module Ordering
  module Adapters
    module Persistence
      module Order
        class Repository < Ordering::Domain::Repositories::Order::Contract
          def initialize(mapper: Mapper.new)
            @mapper = mapper
          end

          def find_by_id(id)
            record = OrderRecord.includes(:order_line_records, :source_video_record).find_by(id: id)
            return unless record

            mapper.to_domain(record)
          end

          def find_by_uid(uid)
            record = OrderRecord.includes(:order_line_records, :source_video_record).find_by(uid: uid.to_s)
            return unless record

            mapper.to_domain(record)
          end

          def save(order)
            record = order.id ? OrderRecord.find_or_initialize_by(id: order.id) : OrderRecord.new
            mapper.write(order, record)
            record.save!
            if record.uid.blank?
              record.update!(uid: Ordering::Domain::ValueObjects::OrderNumber.generate(order_id: record.id).to_s)
            end
            mapper.sync_children!(order, record)
            order.assign_identity!(id: record.id, uid: record.uid)
            order
          end

          def delete(order)
            record = OrderRecord.find_by(id: order.id)
            record&.destroy!
          end

          private

          attr_reader :mapper
        end
      end
    end
  end
end
