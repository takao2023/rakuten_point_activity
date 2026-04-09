class LineReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    current_hour = Time.zone.now.hour
    Rails.logger.info "LineReminderJob 起動: 対象時間 #{current_hour}時"
    
    users = User.joins(:notification_setting, :line_profile)
                .where(notification_settings: { morning_reminder: true })
    
    count = 0

    users.find_each do |user|
      setting_time = user.notification_setting.morning_reminder_time
      next unless setting_time.present? && setting_time.hour == current_hour

      reminders = user.remaining_point_activities
      
      if reminders.any?
        # LINE通知の送信
        if user.line_profile.present?
          flex_content = LineMessageService.remind_flex_message(user, reminders)
          if user.push_flex_message(flex_content)
            count += 1
            user.notification_logs.create!(notification_type: 'morning_reminder', channel: 'line', status: 'sent')
          else
            user.notification_logs.create!(notification_type: 'morning_reminder', channel: 'line', status: 'failed')
          end
        end

        # Web Push通知の送信
        user.push_subscriptions.find_each do |sub|
          begin
            Webpush.payload_send(
              message: { title: "ポイ活リマインド", body: "本日はまだ #{reminders.count}件 のポイ活が残っています！" }.to_json,
              endpoint: sub.endpoint,
              p256dh: sub.p256dh,
              auth: sub.auth,
              vapid: {
                subject: "mailto:support@example.com",
                public_key: ENV['VAPID_PUBLIC_KEY'],
                private_key: ENV['VAPID_PRIVATE_KEY']
              }
            )
            count += 1
            user.notification_logs.create!(notification_type: 'morning_reminder', channel: 'web_push', status: 'sent')
          rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription => e
            sub.destroy # 無効になった購読をクリーンアップ
          rescue StandardError => e
            user.notification_logs.create!(notification_type: 'morning_reminder', channel: 'web_push', status: 'failed', error_message: e.message)
          end
        end
      end
    end

    Rails.logger.info "LineReminderJob 終了: 送信件数 #{count}件"
  end
end
