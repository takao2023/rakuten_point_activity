# 実績マスターデータの投入用シード
achievements = [
  # 🎯 活動数系
  { name: "ポイ活マスター", description: "累計獲得回数が10回を突破しました！", icon: "🎯", condition_type: "count", condition_value: 10 },
  { name: "ポイ活レジェンド", description: "驚異の累計100回達成！あなたはポイ活の神です。", icon: "👑", condition_type: "count", condition_value: 100 },
  { name: "全制覇", description: "すべての種類のポイ活を1回以上達成しました。", icon: "🌈", condition_type: "all_types", condition_value: 0 },

  # 💰 ポイント系
  { name: "1000ポイント突破", description: "累計で1000ポイント獲得しました！", icon: "💰", condition_type: "total_points", condition_value: 1000 },
  { name: "月間100pt", description: "1ヶ月で100ポイント獲得！素晴らしいペースです。", icon: "💎", condition_type: "monthly_points", condition_value: 100 },
  { name: "大漁旗", description: "1回で10ポイント以上の高額獲得を達成しました！", icon: "🚩", condition_type: "single_points", condition_value: 10 },

  # 🔥 連続系
  { name: "1週間継続", description: "7日連続でポイ活を達成しました！", icon: "🔥", condition_type: "streak", condition_value: 7 },
  { name: "1ヶ月継続", description: "30日連続達成！習慣化のプロです。", icon: "🏅", condition_type: "streak", condition_value: 30 },

  # ⏰ 時間帯系
  { name: "早起きポイ活", description: "朝9時前にポイ活を達成しました。三文の得！", icon: "☀️", condition_type: "time_morning", condition_value: 9 },
  { name: "夜活家", description: "22時〜24時の間に静かにポイ活を達成しました。", icon: "🌙", condition_type: "time_night", condition_value: 22 },
  { name: "お昼休み活用", description: "11時〜13時の時間を有効に活用しました。", icon: "🍱", condition_type: "time_lunch", condition_value: 11 },

  # 🎮 ゲーム特化系
  { name: "もぐらたたき名人", description: "ポコポコもぐらたたきを10回達成しました。", icon: "🔨", condition_type: "game_mole", condition_value: 10 },
  { name: "海底探検家", description: "幻の海底神殿を5回達成しました。深海の秘密へ！", icon: "🧜‍♂️", condition_type: "game_sea", condition_value: 5 },
  { name: "じゃんけん王", description: "じゃんけんで累計10ポイント以上を勝ち取りました。", icon: "✊", condition_type: "game_janken", condition_value: 10 },

  # 📅 特定日系
  { name: "元旦ポイ活", description: "1月1日の元旦からポイ活を達成しました！", icon: "㊗️", condition_type: "day_new_year", condition_value: 1 },
  { name: "月初ポイ活", description: "毎月1日のスタートダッシュを決めました！", icon: "🗓️", condition_type: "day_first", condition_value: 1 },
  { name: "記念日活動", description: "アプリ登録記念日にポイ活を達成しました！", icon: "🎉", condition_type: "day_anniversary", condition_value: 1 }
]

achievements.each do |attr|
  Achievement.find_or_create_by!(name: attr[:name]) do |a|
    a.description = attr[:description]
    a.icon = attr[:icon]
    a.condition_type = attr[:condition_type]
    a.condition_value = attr[:condition_value]
  end
end

puts "SUCCESS: Registered #{Achievement.count} achievements."
