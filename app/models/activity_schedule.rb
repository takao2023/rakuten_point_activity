class ActivitySchedule < ApplicationRecord
  belongs_to :point_activity

  validates :frequency, presence: true
end
