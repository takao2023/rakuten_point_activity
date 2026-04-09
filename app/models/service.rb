class Service < ApplicationRecord
  has_many :point_activities, dependent: :destroy
  
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  # 今月のサービス全体の目標ポイントを合算
  def current_month_target(user)
    point_activities.joins(:point_activity_targets)
                    .where(point_activity_targets: { user: user, year_month: Time.zone.today.beginning_of_month })
                    .sum('point_activity_targets.target_point')
  end

  # 今月のサービス全体の累計獲得ポイントを合算
  def current_month_gets(user)
    start_date = Time.zone.today.beginning_of_month
    end_date = Time.zone.today.end_of_month
    point_activities.joins(:point_activity_gets)
                    .where(point_activity_gets: { user: user, created_at: start_date..end_date })
                    .sum('point_activity_gets.get_point')
  end

  # サービス全体の達成率
  def achievement_rate(user)
    target = current_month_target(user)
    return 0 if target == 0
    ((current_month_gets(user).to_f / target) * 100).round
  end
end
