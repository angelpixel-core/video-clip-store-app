class VideoTypeSelection < ApplicationRecord
  belongs_to :project, class_name: "Order", foreign_key: :project_id
  belongs_to :video_type

  delegate :name, :description, :price_cents, :output_format, to: :video_type, prefix: true

  after_create :sync_order_listing
  after_destroy :sync_order_listing

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :video_type_id, uniqueness: { scope: :project_id }

  def sync_order_listing
    project.sync_order_listing! if project.present?
  end

  def offer_variant
    @offer_variant ||= OfferVariant.find_by(name: video_type_name)
  end

  def offer_variant_id
    offer_variant&.id
  end

  def offer_variant_name
    offer_variant&.name || video_type_name
  end

  def offer_variant_price_cents
    offer_variant&.price_cents || video_type_price_cents
  end

  private :sync_order_listing
end
