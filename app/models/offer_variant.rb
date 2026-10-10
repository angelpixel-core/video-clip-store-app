class OfferVariant < ApplicationRecord
  self.table_name = "offer_variants"

  belongs_to :offer
  belongs_to :offer_item_type

  validates :key, presence: true, uniqueness: { scope: :offer_id }
  validates :name, presence: true
  validates :description, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :active, -> { where(active: true) }

  def available?
    Catalog::Domain::Policies::AvailabilityPolicy.available?(self)
  end
end
