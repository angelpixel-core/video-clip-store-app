class Offer < ApplicationRecord
  self.table_name = "offers"

  has_many :offer_item_type_assignments, dependent: :destroy
  has_many :offer_item_types, through: :offer_item_type_assignments
  has_many :offer_variants, dependent: :destroy

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :active, -> { where(active: true) }
end
