class PointActivity < ApplicationRecord
  belongs_to :service
  belongs_to :category
  
  has_many :point_activity_gets, dependent: :destroy
  has_many :point_activity_targets, dependent: :destroy
  has_many :activity_executions, dependent: :destroy

  enum activity_type: { manual: 0, time_managed: 1 }

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

  # 定常的な時間管理・インターバルの判定（5パターン対応）
  def can_execute_now?(user)
    return true unless time_managed?

    today_execs = user.activity_executions.where(point_activity: self, executed_at: Time.current.in_time_zone('Tokyo').beginning_of_day..)

    case time_limit_modes
    when 'rolling'
      # 前回実行からinterval_seconds経過 AND 1日の上限未達
      return false if daily_max_executions && today_execs.count >= daily_max_executions
      last_exec = today_execs.order(executed_at: :desc).first
      return true unless last_exec
      Time.current >= last_exec.executed_at + (interval_seconds || 0).seconds

    when 'fixed_equal'
      # 均等間隔の固定枠（2時間ごと等）
      return false if daily_max_executions && today_execs.count >= daily_max_executions
      window = current_equal_window
      window_execs = today_execs.where(executed_at: window[:start]..window[:end])
      max = per_window_max_executions || 1
      window_execs.count < max

    when 'fixed_custom'
      # 不均等な固定枠（JSONで時間帯を指定）
      return false if daily_max_executions && today_execs.count >= daily_max_executions
      window = current_custom_window
      return false unless window # 現在どの枠にも属していない
      window_execs = today_execs.where(executed_at: window[:start]..window[:end])
      max = per_window_max_executions || 1
      window_execs.count < max

    when 'daily'
      # 1日N回（0:00リセット）
      max = daily_max_executions || 1
      today_execs.count < max

    when 'weekly'
      # 週N回（月曜0:00リセット）
      week_start = Time.current.in_time_zone('Tokyo').beginning_of_week
      week_execs = user.activity_executions.where(point_activity: self, executed_at: week_start..)
      max = daily_max_executions || 1
      week_execs.count < max

    else
      true
    end
  end

  def next_available_time(user)
    case time_limit_modes
    when 'rolling'
      last_exec = user.activity_executions.where(point_activity: self).order(executed_at: :desc).first
      return Time.current unless last_exec
      last_exec.executed_at + (interval_seconds || 0).seconds

    when 'fixed_equal'
      window = current_equal_window
      window[:end] + 1.second # 次の枠の開始

    when 'fixed_custom'
      window = current_custom_window
      return tomorrow_start unless window
      # 次のカスタム枠を探す
      next_window = find_next_custom_window
      next_window ? next_window[:start] : tomorrow_start

    when 'daily'
      tomorrow_start

    when 'weekly'
      Time.current.in_time_zone('Tokyo').next_week.beginning_of_week

    else
      Time.current
    end
  end

  # 今日の実行回数を取得
  def today_execution_count(user)
    user.activity_executions.where(point_activity: self, executed_at: Time.current.in_time_zone('Tokyo').beginning_of_day..).count
  end

  # 星の数に応じたオススメ度タイトル（3段階）
  def recommendation_stars
    "★" * (recommendation_level || 1)
  end

  validates :recommendation_level, inclusion: { in: 1..3 }
  validates :major_item, presence: true

  private

  # 均等間隔の現在の枠を計算
  def current_equal_window
    tz = Time.current.in_time_zone('Tokyo')
    window_hours = (interval_seconds || 7200) / 3600
    window_index = tz.hour / window_hours
    start_time = tz.beginning_of_day + (window_index * window_hours).hours
    end_time = start_time + window_hours.hours - 1.second
    { start: start_time, end: end_time }
  end

  # カスタム枠から現在の枠を特定
  def current_custom_window
    return nil unless custom_windows.is_a?(Array)
    tz = Time.current.in_time_zone('Tokyo')
    today = tz.beginning_of_day

    custom_windows.each do |window_str|
      times = parse_window_string(window_str, today)
      return times if tz >= times[:start] && tz <= times[:end]
    end
    nil
  end

  # 次のカスタム枠を検索
  def find_next_custom_window
    return nil unless custom_windows.is_a?(Array)
    tz = Time.current.in_time_zone('Tokyo')
    today = tz.beginning_of_day

    custom_windows.each do |window_str|
      times = parse_window_string(window_str, today)
      return times if times[:start] > tz
    end
    # 今日の枠がすべて終了 → 明日の最初の枠
    tomorrow = today + 1.day
    first_window = parse_window_string(custom_windows.first, tomorrow)
    first_window
  end

  # "HH:MM-HH:MM" 形式の文字列をパース
  def parse_window_string(str, base_date)
    parts = str.split('-')
    start_h, start_m = parts[0].strip.split(':').map(&:to_i)
    end_h, end_m = parts[1].strip.split(':').map(&:to_i)
    {
      start: base_date + start_h.hours + start_m.minutes,
      end: base_date + end_h.hours + end_m.minutes + 59.seconds
    }
  end

  def tomorrow_start
    Time.current.in_time_zone('Tokyo').beginning_of_day + 1.day
  end
end
