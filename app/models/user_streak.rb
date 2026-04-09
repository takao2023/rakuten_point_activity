class UserStreak < ApplicationRecord
  belongs_to :user

  validates :current_streak, numericality: { greater_than_or_equal_to: 0 }

  # ストリークを更新する
  def update_streak!
    today = Time.zone.today
    
    if last_completed_date == today
      # すでに今日完了している場合は何もしない
      return
    elsif last_completed_date == today - 1
      # 昨日完了していた場合は＋1
      self.current_streak += 1
    else
      # それ以外（1日以上空いた）はリセット
      self.current_streak = 1
    end

    self.longest_streak = [longest_streak, current_streak].max
    self.last_completed_date = today
    save!
  end
end
