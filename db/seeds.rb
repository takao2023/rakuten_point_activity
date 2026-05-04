# 既存データの全削除
puts "Cleaning up database..."
PointActivityTarget.delete_all
PointActivityGet.delete_all
PointActivity.delete_all
Category.delete_all
Service.delete_all

puts "Seeding Categories..."
categories_data = [
  { code: "C01", name: "広告タップ" },
  { code: "C02", name: "ゲームクリア" },
  { code: "C03", name: "毎日くじ" },
  { code: "C04", name: "ミッションクリア" },
  { code: "C05", name: "ながら" },
  { code: "C06", name: "その他" }
]
categories = {}
categories_data.each do |data|
  categories[data[:code]] = Category.create!(data)
end

puts "Seeding Services..."
services_data = [
  { code: "S01", name: "楽天スーパーポイントスクリーン", platform: "アプリ", official_url: "", recommended_points: 550, icon: "bi-phone" },
  { code: "S02", name: "楽天ウェブ検索", platform: "ブラウザ/アプリ", official_url: "https://r10.to/hPscUv", recommended_points: 30, icon: "bi-search" },
  { code: "S03", name: "楽天PointMall", platform: "ブラウザ", official_url: "https://pointmall.rakuten.co.jp/" , recommended_points: 200},
  { code: "S04", name: "Rakuten Link", platform: "アプリ", official_url: "" , recommended_points: 50},
  { code: "S05", name: "R チャンネル", platform: "ブラウザ/アプリ", official_url: "https://channel.rakuten.co.jp/", recommended_points: 850, icon: "bi-tv" },
  { code: "S06", name: "楽天ペイ", platform: "アプリ", official_url: "" , recommended_points: 10},
  { code: "S07", name: "楽天PointClub", platform: "アプリ", official_url: "" , recommended_points: 5},
  { code: "S08", name: "楽天ポイントモール", platform: "アプリ", official_url: "" , recommended_points: 25}
]
services = {}
services_data.each do |data|
  services[data[:code]] = Service.create!(data)
end

puts "Seeding PointActivities..."
# 画像の表に基づいたデータ
activities = [
  # S01 (楽天SPS)
  { service_code: "S01", category_code: "C01", major: "ポイント獲得", small: "楽天SPS", freq: "1回/day", stars: 3, strategy_url: "https://note.com/quiet_hound2606/n/n1cf0341732e3" },
  { service_code: "S01", category_code: "C01", major: "ポイント獲得", small: "Rakuten Link", freq: "", stars: 3, strategy_url: "https://note.com/quiet_hound2606/n/n1cf0341732e3" },
  { service_code: "S01", category_code: "C01", major: "ポイント獲得", small: "楽天ペイ", freq: "", stars: 3, strategy_url: "https://note.com/quiet_hound2606/n/n1cf0341732e3" },
  { service_code: "S01", category_code: "C01", major: "ポイント獲得", small: "楽天PointClub", freq: "", stars: 3, strategy_url: "https://note.com/quiet_hound2606/n/n1cf0341732e3" },
  { service_code: "S01", category_code: "C03", major: "ダーツ", small: "", freq: "1回/day", stars: 1 },
  
  # S02 (楽天ウェブ検索)
  { service_code: "S02", category_code: "C05", major: "楽天ウェブ検索で検索！", small: "", freq: "", stars: 3 },

  # S05 (R チャンネル)
  { service_code: "S05", category_code: "C05", major: "R チャンネルで動画視聴！", small: "", freq: "1回/3h", stars: 3 },

  # S03 (楽天PointMall - Browser)
  { service_code: "S03", category_code: "C02", major: "ポコポコもぐらたたき", small: "たたくモード", freq: "1回/2h", stars: 2 },
  { service_code: "S03", category_code: "C02", major: "ポコポコもぐらたたき", small: "にげるモード", freq: "1回/day", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "ポコポコもぐらたたき", small: "さがすモード", freq: "3回/day", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "ポコポコもぐらたたき", small: "ミニゲーム", freq: "1回/2h", stars: 1 },
  { service_code: "S03", category_code: "C04", major: "賢者の難問クイズ", small: "通常クイズ", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C04", major: "賢者の難問クイズ", small: "特集クイズ", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C04", major: "賢者の難問クイズ", small: "ミッション", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C02", major: "幻の海底神殿", small: "ゲームTOP", freq: "2回/day", stars: 2 },
  { service_code: "S03", category_code: "C02", major: "幻の海底神殿", small: "サブゲーム", freq: "1回/day", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "トレジャーBINGO", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "遺跡探検すごろく", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "たびろく", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "クラッシュアイス", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "スロットパラダイス", small: "", freq: "", stars: 2 },
  { service_code: "S03", category_code: "C02", major: "ぷくぷくラグーン", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "みんなのフルーツ農場生活", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "頭の体操ミニゲーム", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C02", major: "どこどこ？まちがい探し", small: "", freq: "", stars: 1 },
  { service_code: "S03", category_code: "C03", major: "モールガチャ", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C03", major: "スクラッチ", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C03", major: "じゃんけん", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C03", major: "モールみくじ", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S03", category_code: "C03", major: "ドリームくじ", small: "", freq: "", stars: 3 },

  # S08 (楽天ポイントモール - App)
  { service_code: "S08", category_code: "C03", major: "デイリーガチャ", small: "", freq: "2回/day", stars: 3 },
  { service_code: "S08", category_code: "C03", major: "海底大作戦くじ", small: "", freq: "2回/day", stars: 3 },
  { service_code: "S08", category_code: "C03", major: "竜宮探索くじ", small: "", freq: "2回/day", stars: 3 },
  { service_code: "S08", category_code: "C03", major: "みこくじ", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S08", category_code: "C03", major: "ゆみくじ", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S08", category_code: "C01", major: "動画チェック", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S08", category_code: "C04", major: "宝箱", small: "", freq: "1回/day", stars: 3 },

  # S04 (Rakuten Link)
  { service_code: "S04", category_code: "C05", major: "ミッション", small: "", freq: "6回/week", stars: 3 },
  { service_code: "S04", category_code: "C04", major: "ニュース", small: "", freq: "1回/day", stars: 3 },

  # S06 (楽天ペイ)
  { service_code: "S06", category_code: "C06", major: "ジャンケン", small: "", freq: "1回/day", stars: 1 },
  { service_code: "S06", category_code: "C06", major: "クーポン", small: "", freq: "", stars: 2 },

  # S07 (楽天PointClub)
  { service_code: "S07", category_code: "C06", major: "利息", small: "", freq: "1回/day", stars: 3 },
  { service_code: "S07", category_code: "C03", major: "ラッキーくじ", small: "", freq: "2回/day", stars: 1 }
]

activities.each do |data|
  # 完了報告対象カテゴリかどうか
  is_completion_tab = ["毎日くじ", "ゲームクリア", "ミッションクリア"].include?(categories[data[:category_code]].name)

  # 頻度からモードを判定
  mode = 'daily'
  interval = nil
  if data[:freq].to_s.include?('2h')
    mode = 'fixed_equal'
    interval = 7200
  elsif data[:freq].to_s.include?('3h')
    mode = 'fixed_equal'
    interval = 10800
  elsif data[:freq].to_s.include?('12h') || (data[:major] == "幻の海底神殿" && data[:small] == "ゲームTOP")
    mode = 'fixed_equal'
    interval = 43200
  elsif data[:freq].to_s.include?('week')
    mode = 'weekly'
  end

  PointActivity.create!(
    service: services[data[:service_code]],
    category: categories[data[:category_code]],
    major_item: data[:major],
    small_item: data[:small],
    frequency: data[:freq],
    recommendation_level: data[:stars],
    strategy_url: data[:strategy_url],
    activity_type: is_completion_tab ? 1 : 0, # カテゴリに応じて切替
    time_limit_modes: mode,
    interval_seconds: interval,
    executions_per_reward: 1,
    per_window_max_executions: 1,
    daily_max_executions: data[:freq].to_s.scan(/\d+/).first&.to_i || 1,
    description: "#{services[data[:service_code]].name} of #{data[:major]}#{data[:small].present? ? "（#{data[:small]}）" : ""}です。"
  )
end

puts "Database seeded successfully!"
puts "Services: #{Service.count}, Categories: #{Category.count}, Activities: #{PointActivity.count}"

# 本番・ローカル共通で実績データマスターも登録する
require_relative 'seeds/seed_achievements'
