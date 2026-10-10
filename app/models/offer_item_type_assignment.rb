class OfferItemTypeAssignment < ApplicationRecord
  self.table_name = "offer_item_type_assignments"

  belongs_to :offer
  belongs_to :offer_item_type

  validates :offer_id, uniqueness: { scope: :offer_item_type_id }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :min_selections, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_selections, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
