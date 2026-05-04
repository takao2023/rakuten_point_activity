class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_course_selection, only: [:index]

  def index
    # 完了ボタンを「1回のタップ」に統一 (広告タップ以外)
    # executions_per_reward（報酬までの回数）を1に、per_window_max_executions（1枠あたりの回数）を1に設定
    non_ad_categories = Category.where.not(name: '広告タップ').pluck(:id)
    PointActivity.where(category_id: non_ad_categories).update_all(executions_per_reward: 1, per_window_max_executions: 1)

    @today_date = Time.zone.today
    @this_month_start = @today_date.beginning_of_month
    @this_month_end = @today_date.end_of_month

    @today_points = current_user.point_activity_gets.where(created_at: @today_date.beginning_of_day..@today_date.end_of_day).sum(:get_point)
    @monthly_activity_count = current_user.point_activity_gets.where(created_at: @this_month_start..@this_month_end).count
    
    # 今日の実行回数（ActivityExecutionベース）
    @today_executions_count = current_user.activity_executions.where(executed_at: @today_date.beginning_of_day..@today_date.end_of_day).count
    @month_executions_count = current_user.activity_executions.where(executed_at: @this_month_start..@this_month_end).count
    @month_points = current_user.point_activity_gets.where(created_at: @this_month_start..@this_month_end).sum(:get_point)
    @total_target_points = current_user.point_activity_targets.where(year_month: @this_month_start).sum(:target_point)

    # 現在プレイ可能なアクティビティ数
    @time_managed_activities = PointActivity.time_managed.includes(:service, :category)
    @ready_activities = @time_managed_activities.select { |pa| pa.can_execute_now?(current_user) }
    @ready_activities_count = @ready_activities.count
    @total_time_managed_count = @time_managed_activities.count

    # ポイ活構成比（利用率）データ作成
    # 1. 昨日の集計 (JST基準)
    yesterday_totals = current_user.activity_executions
      .where(executed_at: 1.day.ago.in_time_zone('Tokyo').all_day)
      .group(:point_activity_id)
      .count

    # 2. 今日の集計 (JST基準)
    execution_totals_raw = current_user.activity_executions
      .where(executed_at: Time.current.in_time_zone('Tokyo').all_day)
      .group(:point_activity_id)
      .count

    # 表示名を含めたデータに変換する共通処理
    target_activity_ids = (yesterday_totals.keys + execution_totals_raw.keys).uniq
    target_activities = PointActivity.where(id: target_activity_ids).index_by(&:id)

    def display_name(activity)
      return "不明な活動" unless activity
      activity.small_item.present? ? "#{activity.major_item}（#{activity.small_item}）" : activity.major_item
    end

    # 3. 今日の完了全量（リスト表示用）
    @today_execution_totals = execution_totals_raw.map do |id, count|
      [display_name(target_activities[id]), count]
    end.sort_by { |_, v| -v }.to_h

    # 4. 減少している項目の抽出（前日比減）
    @decreased_activities = []
    yesterday_totals.each do |id, y_count|
      t_count = execution_totals_raw[id] || 0
      if t_count < y_count
        @decreased_activities << { 
          item: display_name(target_activities[id]), 
          yesterday: y_count, 
          today: t_count, 
          diff: y_count - t_count 
        }
      end
    end
    @decreased_activities.sort_by! { |d| -d[:diff] }
    @decreased_activities = @decreased_activities.first(5)
    
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

    # 🏆 オススメ攻略記事 (strategy_url が設定されているもの)
    @strategy_activities = PointActivity.includes(:service)
      .where.not(strategy_url: [nil, ""])
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

    # 昨日の獲得ポイント (初回ログインモーダル用)
    @yesterday_points = current_user.point_activity_gets
                                    .where(created_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day)
                                    .sum(:get_point)

    # --- バーンアップチャートのデータ作成 ---
    days_in_month = @today_date.end_of_month.day
    actual_data = {}
    ideal_data = {}
    target_data = {}
    
    # 実際の実績（累積前の日別合計）
    daily_gets = current_user.point_activity_gets
      .where(created_at: @this_month_start..@this_month_end)
      .group_by_day(:created_at)
      .sum(:get_point)
    
    cumulative_points = 0
    (1..days_in_month).each do |day|
      date = @this_month_start + (day - 1).days
      label = date.strftime("%-d")
      
      # 目標ライン（常に一定）
      target_data[label] = @total_target_points
      
      # 理想ライン（1日あたりの平均獲得目標を積み上げ）
      ideal_data[label] = ((@total_target_points.to_f / days_in_month) * day).round(0)
      
      # 実績ライン（累積）
      if date <= @today_date
        cumulative_points += (daily_gets[date] || 0)
        actual_data[label] = cumulative_points
      end
    end
    
    @burnup_chart_data = [
      { name: "目標", data: target_data, color: "#cbd5e1" }, # 薄いグレー
      { name: "理想", data: ideal_data, color: "#6366f1", library: { borderDash: [5, 5] } }, # 青の点線
      { name: "実績", data: actual_data, color: "#10b981" } # 緑
    ]
  end
end
