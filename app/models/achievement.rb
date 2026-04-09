class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements

  validates :name, presence: true, uniqueness: true
  validates :condition_type, presence: true

  # 提供されたカテゴリの定数（任意）
  TYPES = %w[activity_count total_points monthly_points single_points streak time_of_day game_specific special_day].freeze

  def self.check_and_award!(user, latest_get = nil)
    AchievementService.new(user).check_all(latest_get)
  end
end
