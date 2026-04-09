class DailyTask < ApplicationRecord
  belongs_to :user
  belongs_to :point_activity

  validates :task_date, presence: true
end
