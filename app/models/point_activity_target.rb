class PointActivityTarget < ApplicationRecord
  belongs_to :user
  belongs_to :get_point, optional: true
  belongs_to :point_activity

  validates :target_point, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :year_month, presence: true
end
