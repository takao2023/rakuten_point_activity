activities = [
  "ポコポコもぐらたたき",
  "スロットパラダイス",
  "幻の海底神殿",
  "ぷくぷくラグーン",
  "賢者の難問クイズ",
  "モールくじ ガチャ",
  "モールくじ スクラッチ",
  "モールくじ じゃんけん",
  "ドリームくじ",
  "Rakutenチャンネル",
  "楽天PointClub",
  "R Point Screen",
  "R Link ミッション",
  "R Link ラッキーくじ"
]

activities.each do |activity_title|
  PointActivity.create!(point_activity_title: activity_title)
end
