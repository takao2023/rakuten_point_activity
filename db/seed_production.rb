# 本番環境用: テストデータ投入スクリプト
# Cloud Run Job で `bin/rails runner db/seed_production.rb` として実行

# ① ポコポコもぐらたたき（大項目: 3ポイント/日）
parent1 = PointActivity.find_or_create_by!(point_activity_title: "ポコポコもぐらたたき")
parent1.update!(average_points: 3)

# 小項目
[
  ["たたくモード", 1],   # 60秒
  ["にげるモード", 1],   # 60秒
  ["さがすモード", 3],   # 180秒
  ["ミニゲーム", 1]      # 30秒
].each do |title, minutes|
  PointActivity.find_or_create_by!(point_activity_title: title, parent_id: parent1.id) do |c|
    c.estimated_minutes = minutes
  end
end

# ② 幻の海底神殿（大項目: 5ポイント/日）
parent2 = PointActivity.find_or_create_by!(point_activity_title: "幻の海底神殿")
parent2.update!(average_points: 5)

# 小項目
[
  ["ゲームTOP", 10],  # 10分
  ["サブゲーム", 5]    # 5分
].each do |title, minutes|
  PointActivity.find_or_create_by!(point_activity_title: title, parent_id: parent2.id) do |c|
    c.estimated_minutes = minutes
  end
end

# その他の大項目（既存のもの）
%w[
  スロットパラダイス
  ぷくぷくラグーン
  賢者の難問クイズ
].each { |t| PointActivity.find_or_create_by!(point_activity_title: t) }

["モールくじ ガチャ", "モールくじ スクラッチ", "モールくじ じゃんけん",
 "ドリームくじ", "Rakutenチャンネル", "楽天PointClub",
 "R Point Screen", "R Link ミッション", "R Link ラッキーくじ"].each do |t|
  PointActivity.find_or_create_by!(point_activity_title: t)
end

# 実績バッジ
[
  { name: "ポイ活ビギナー", description: "初めてポイ活を達成した", icon: "🌱", condition_type: "activities_count", condition_value: 1 },
  { name: "チリツモ名人", description: "累計100ポイント獲得", icon: "🪙", condition_type: "total_points", condition_value: 100 },
  { name: "3日坊主卒業", description: "3日連続でポイ活達成", icon: "🔥", condition_type: "streak", condition_value: 3 }
].each do |ach_params|
  Achievement.find_or_create_by!(name: ach_params[:name]) do |a|
    a.description = ach_params[:description]
    a.icon = ach_params[:icon]
    a.condition_type = ach_params[:condition_type]
    a.condition_value = ach_params[:condition_value]
  end
end

puts "=== シードデータ投入完了 ==="
puts "PointActivity 合計: #{PointActivity.count}"
puts "  大項目: #{PointActivity.where(parent_id: nil).count}"
puts "  小項目: #{PointActivity.where.not(parent_id: nil).count}"
puts "Achievement: #{Achievement.count}"
