parent1 = PointActivity.find_by(point_activity_title: "ポコポコもぐらたたき")
if parent1
  ["たたくモード", "にげるモード", "さがすモード", "ミニゲーム"].each do |title|
    child = PointActivity.find_by(point_activity_title: title)
    child&.update!(parent_id: parent1.id)
  end
  puts "ポコポコもぐらたたき: done"
end

parent2 = PointActivity.find_by(point_activity_title: "幻の海底神殿")
if parent2
  ["ゲームTOP", "サブゲーム"].each do |title|
    child = PointActivity.find_by(point_activity_title: title)
    child&.update!(parent_id: parent2.id)
  end
  puts "幻の海底神殿: done"
end

puts "Complete!"
