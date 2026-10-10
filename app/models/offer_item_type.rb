class OfferItemType < ApplicationRecord
  self.table_name = "offer_item_types"

  has_many :offer_item_type_assignments, dependent: :destroy
  has_many :offers, through: :offer_item_type_assignments
  has_many :offer_variants, dependent: :nullify

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :input_kind, presence: true

  scope :active, -> { where(active: true) }
end
