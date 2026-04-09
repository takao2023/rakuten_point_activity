class PointActivityTargetService
  def upsert_for_current_month(user:, point_activity_id:, target_point:)
    target = PointActivityTarget.find_or_initialize_by(
      user_id: user.id,
      point_activity_id: point_activity_id,
      year_month: Date.today.beginning_of_month
    )
    target.target_point = target_point
    target.save
  rescue StandardError => e
    Rails.logger.error("PointActivityTargetService#upsert_for_current_month Error: #{e.message}")
    false
  end
end
