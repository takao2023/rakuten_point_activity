class LineReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    now = Time.zone.now
    # 0分〜29分なら .0、 30分〜59分なら .5 とする
    current_time_val = now.hour + (now.min >= 30 ? 0.5 : 0.0)
    Rails.logger.info "LineReminderJob 起動: 対象時間 #{current_time_val}時"
    
    users = User.joins(:notification_setting, :line_profile)
                .where(notification_settings: { morning_reminder: true })
    
    count = 0

    users.find_each do |user|
      # 複数リマインド時間に対応（reminder_hours を優先し、未設定なら morning_reminder_time にフォールバック）
      next unless user.notification_setting.should_remind_at?(current_time_val)

      reminders = user.ready_point_activities
      
      if reminders.any?
        # コースによるLINE通知の制限
        skip_line_notification = %w[super_beginner beginner].include?(user.selected_course) || (user.selected_course == 'intermediate' && current_time_val.to_i == 8)

        # LINE通知の送信
        if user.line_profile.present? && !skip_line_notification
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
              message: { title: "ポイ活リマインド", body: "現在 #{reminders.count}件 のポイ活がプレイ可能です！✨" }.to_json,
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
