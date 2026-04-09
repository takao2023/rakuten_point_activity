class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @today_date = Time.zone.today
    @this_month_start = @today_date.beginning_of_month
    @this_month_end = @today_date.end_of_month

    @target_points = current_user.point_activity_targets.sum(:target_point)
    @today_points = current_user.point_activity_gets.where(created_at: @today_date.beginning_of_day..@today_date.end_of_day).sum(:get_point)
    
    # 当月の獲得合計
    @month_points = current_user.point_activity_gets.where(created_at: @this_month_start..@this_month_end).sum(:get_point)
    @monthly_activity_count = current_user.point_activity_gets.where(created_at: @this_month_start..@this_month_end).count
    
    # プログレスバー計算用
    @days_in_month = @today_date.end_of_month.day
    # (今月の目標ポイント / 今月の日数) = 1日あたりの必要平均。これが分母。
    daily_pace_denominator = @target_points > 0 ? (@target_points.to_f / @days_in_month) : 0
    @today_pace_percent = daily_pace_denominator > 0 ? ((@today_points.to_f / daily_pace_denominator) * 100).round : 0
    @month_achievement_percent = @target_points > 0 ? ((@month_points.to_f / @target_points) * 100).round : 0
    
    # ポイ活構成比（利用率）データ作成
    # 1. 大項目（親カテゴリー）ごとに集計し、降順にソート
    category_totals = current_user.point_activity_gets
      .where(created_at: @this_month_start..@this_month_end)
      .joins(point_activity: :service)
      .group('services.name')
      .sum(:get_point)
      .sort_by { |_, v| -v }

    # 2. 上位5件とそれ以外（6位以下）に分割
    @activity_usage_data_top = category_totals.first(5).to_h
    @activity_usage_data_low = category_totals.size > 5 ? category_totals[5..-1].to_h : {}
    
    # グラフ中央に表示するそれぞれの合計点
    @month_points_top = @activity_usage_data_top.values.sum
    @month_points_low = @activity_usage_data_low.values.sum
    
    # 円グラフの配色パレット
    @chart_colors = ["#6366f1", "#10b981", "#f59e0b", "#ec4899", "#8b5cf6", "#06b6d4"]

    # 📊 過去30日間の日別獲得ポイント推移
    @daily_chart_data = current_user.point_activity_gets
      .where(created_at: 30.days.ago.beginning_of_day..Time.zone.now)
      .group_by_day(:created_at, format: "%-m/%-d")
      .sum(:get_point)

    # 📊 過去12週間の週別獲得ポイント推移
    @weekly_chart_data = current_user.point_activity_gets
      .where(created_at: 12.weeks.ago.beginning_of_day..Time.zone.now)
      .group_by_week(:created_at, format: "%-m/%-d〜")
      .sum(:get_point)

    # 🏆 オススメ度(★)が高いポイ活
    @recommended_activities = PointActivity.includes(:service)
      .where("recommendation_level >= ?", 3)
      .order(recommendation_level: :desc)
      .limit(5)

    # 時間帯に応じた挨拶の決定 (JST)
    current_hour = Time.zone.now.hour
    if current_hour >= 4 && current_hour < 11
      @greeting = "おはようございます！"
      @greeting_emoji = "🌅"
    elsif current_hour >= 11 && current_hour < 17
      @greeting = "こんにちは！"
      @greeting_emoji = "☀️"
    else
      @greeting = "こんばんは！"
      @greeting_emoji = "🌙"
    end

    @point_activities = PointActivity.all
    @user_streak = current_user.user_streak || current_user.create_user_streak

    # 📅 近日開催のキャンペーン (今日から7日以内)
    @upcoming_campaigns = Campaign.where(start_at: @today_date.beginning_of_day..7.days.from_now.end_of_day)
                                  .order(:start_at)
                                  .limit(3)

    # 🤖 最新のAIアドバイスを取得
    @latest_ai_advice = current_user.ai_advices.order(generated_at: :desc).first
  end
end
