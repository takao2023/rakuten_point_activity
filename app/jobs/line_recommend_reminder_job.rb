class LineRecommendReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    current_hour = Time.zone.now.hour
    Rails.logger.info "LineRecommendReminderJob 起動: 対象時間 #{current_hour}時"
    
    settings = NotificationSetting
               .where(morning_reminder: true, notification_channel: "line")
               .includes(:user)

    count = 0
    settings.find_each do |setting|
      # 複数リマインド時間に対応
      next unless setting.should_remind_at?(current_hour)

      user = setting.user
      next unless user

      target_month = Date.today.beginning_of_month
      set_target_ids = user.point_activity_targets.where(year_month: target_month).where("target_point > 0").pluck(:point_activity_id)
      missing_activities = PointActivity.where.not(id: set_target_ids)
      
      next if missing_activities.empty?

      activity_list_text = missing_activities.map { |a| "・#{a.point_activity_title}" }.join("\n")
      
      message = <<~TEXT
        【ポイ活レコメンド】
        以下のポイ活の今月の目標がまだ設定されていません！
        #{activity_list_text}
        
        目標を設定してポイ活を習慣化しましょう💡
      TEXT
      
      begin
        result = user.send_line_message(message.strip)
        # HTTP response from line-bot-api is returned
        if result && result.code == '200'
          user.notification_logs.create!(
            notification_type: "recommend",
            channel: "line",
            status: "success",
            content: message.strip
          )
        else
          error_body = result.body rescue "Unknown error"
          user.notification_logs.create!(
            notification_type: "recommend",
            channel: "line",
            status: "error",
            content: message.strip,
            error_message: "HTTP #{result&.code}: #{error_body}"
          )
        end
        count += 1
      rescue => e
        user.notification_logs.create!(
          notification_type: "recommend",
          channel: "line",
          status: "error",
          content: message.strip,
          error_message: e.message
        )
      end
    end
    Rails.logger.info "LineRecommendReminderJob 終了: 送信件数 #{count}件"
  end
end
