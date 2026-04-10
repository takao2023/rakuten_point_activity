# 本番環境での確認用：ダミーデータの投入ロジック
# ダッシュボードおよびAIバトラーを検証するため、仮の目標と実績を作成します。

user = User.first
unless user
  puts "====================="
  puts "テスト用のユーザーが存在しません。先にログイン/会員登録をしてから実行してください。"
  puts "====================="
  exit
end

puts "Creating dummy targets, points, and streaks for [#{user.email}] ..."

# クリーンアップ（リセット）
PointActivityGet.where(user: user).delete_all
PointActivityTarget.where(user: user).delete_all
UserStreak.where(user: user).delete_all
DailyTask.where(user: user).delete_all

# レコメンド度が高い活動を目標に設定
activities = PointActivity.where(recommendation_level: 3).limit(5)
month_start = Time.zone.today.beginning_of_month

activities.each do |act|
  PointActivityTarget.create!(
    user: user,
    point_activity: act,
    year_month: month_start,
    target_point: 10,
    priority_score: rand(5.0..10.0).round(1)
  )
end

# 過去7日分の獲得実績とデーリータスクを作成
7.downto(0) do |days_ago|
  date = days_ago.days.ago
  
  activities.sample(rand(2..4)).each do |act|
    # ポイント獲得
    PointActivityGet.create!(
      user: user,
      point_activity: act,
      get_point: act.major_item.include?("クイズ") ? 5 : 2,
      created_at: date,
      updated_at: date
    )
    
    # タスクの完了を記録
    DailyTask.create!(
      user: user,
      point_activity: act,
      task_date: date.to_date,
      completed: true,
      completed_at: date
    )
  end
end

# ストリーク（連続達成記録）を生成（AI用に褒められるように設定）
UserStreak.create!(
  user: user,
  current_streak: 8,
  longest_streak: 15,
  last_completed_date: Time.zone.today
)

puts "====================="
puts "SUCCESS: Dummy data successfully registered! AI Butler is ready."
puts "====================="
