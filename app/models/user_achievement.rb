class UserAchievement < ApplicationRecord
  belongs_to :user
  belongs_to :achievement

  validates :user_id, uniqueness: { scope: :achievement_id, message: "は既にこの実績を獲得しています" }
  validates :earned_at, presence: true

  before_validation :set_earned_at, on: :create

  private

  def set_earned_at
    self.earned_at ||= Time.current
  end
end
