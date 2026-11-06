module Ordering
  module Adapters
    module Persistence
      module Order
        class SourceVideoRecord < ApplicationRecord
          self.table_name = "source_videos"

          belongs_to :order_record, class_name: "Ordering::Adapters::Persistence::Order::OrderRecord", foreign_key: :order_id, inverse_of: :source_video_record
        end
      end
    end
  end
end
