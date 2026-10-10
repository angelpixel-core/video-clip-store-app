class VideoType < ApplicationRecord
  self.table_name = "video_types"

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :output_format, presence: true

  def available?
    Catalog::Domain::Policies::AvailabilityPolicy.available?(self)
  end
end
