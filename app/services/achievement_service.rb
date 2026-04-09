class AchievementService
  def initialize(user)
    @user = user
  end

  def check_all(latest_get = nil)
    # 未獲得の実績をすべて取得
    unearned_achievements = Achievement.where.not(id: @user.achievement_ids)
    
    earned_new = []

    unearned_achievements.each do |achievement|
      if criteria_met?(achievement, latest_get)
        UserAchievement.create!(user: @user, achievement: achievement)
        earned_new << achievement
      end
    end

    earned_new
  end

  private

  def criteria_met?(achievement, latest_get)
    case achievement.condition_type
    when "count"
      @user.point_activity_gets.count >= achievement.condition_value
    when "total_points"
      @user.point_activity_gets.sum(:get_point) >= achievement.condition_value
    when "all_types"
      # 全種類のポイ活を達成したか
      distinct_gets = @user.point_activity_gets.distinct.count(:point_activity_id)
      total_activities = PointActivity.where(parent_id: nil).count # トップレベル項目数で判定
      distinct_gets >= total_activities && total_activities > 0
    when "monthly_points"
      @user.point_activity_gets.where(created_at: Time.current.all_month).sum(:get_point) >= achievement.condition_value
    when "single_points"
      latest_get && latest_get.get_point >= achievement.condition_value
    when "streak"
      streak = @user.user_streak
      streak && streak.current_streak >= achievement.condition_value
    when "time_morning"
      latest_get && latest_get.created_at.in_time_zone("Tokyo").hour < achievement.condition_value
    when "time_night"
      latest_get && latest_get.created_at.in_time_zone("Tokyo").hour >= achievement.condition_value
    when "time_lunch"
      latest_get && latest_get.created_at.in_time_zone("Tokyo").hour.between?(11, 13)
    when "game_mole"
      @user.point_activity_gets.joins(:point_activity).where(point_activities: { point_activity_title: "ポコポコもぐらたたき" }).count >= achievement.condition_value
    when "game_sea"
      @user.point_activity_gets.joins(:point_activity).where(point_activities: { point_activity_title: "幻の海底神殿" }).count >= achievement.condition_value
    when "game_janken"
      @user.point_activity_gets.joins(:point_activity).where("point_activities.point_activity_title LIKE ?", "%じゃんけん%").sum(:get_point) >= achievement.condition_value
    when "day_new_year"
      Time.current.month == 1 && Time.current.day == 1
    when "day_first"
      Time.current.day == 1
    when "day_anniversary"
      @user.created_at.to_date == Time.zone.today
    else
      false
    end
  end
end
