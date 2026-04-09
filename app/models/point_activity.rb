class PointActivity < ApplicationRecord
  belongs_to :service
  belongs_to :category
  
  has_many :point_activity_gets, dependent: :destroy
  has_many :point_activity_targets, dependent: :destroy

  # 今月の目標ポイントを取得
  def current_month_target(user)
    point_activity_targets.where(user: user, year_month: Time.zone.today.beginning_of_month).first&.target_point || 0
  end

  # 今月の累計獲得ポイントを取得
  def current_month_gets(user)
    start_date = Time.zone.today.beginning_of_month
    end_date = Time.zone.today.end_of_month
    point_activity_gets.where(user: user, created_at: start_date..end_date).sum(:get_point)
  end

  # 今月の目標設定レコードのIDを取得
  def current_target_id(user)
    point_activity_targets.where(user: user, year_month: Time.zone.today.beginning_of_month).first&.id
  end

  # 達成率を計算
  def achievement_rate(user)
    target = current_month_target(user)
    return 0 if target == 0
    ((current_month_gets(user).to_f / target) * 100).round
  end

  # 表示用タイトル
  def full_title
    "#{service.name} > #{major_item}#{small_item.present? ? "（#{small_item}）" : ""}"
  end

  # 星の数に応じたオススメ度タイトル（3段階）
  def recommendation_stars
    "★" * recommendation_level
  end

  validates :recommendation_level, inclusion: { in: 1..3 }
  validates :major_item, presence: true
end
