class NotificationSetting < ApplicationRecord
  belongs_to :user

  # reminder_hours カラムを JSON 配列として扱う（例: [8, 11, 18, 22]）
  serialize :reminder_hours, coder: JSON

  # 指定された時刻（hour）がリマインド対象かどうかを判定
  def should_remind_at?(hour)
    hours = reminder_hours.presence || []
    # 旧仕様（morning_reminder_time）との後方互換性を維持
    if hours.empty? && morning_reminder_time.present?
      return morning_reminder_time.hour == hour
    end
    hours.include?(hour)
  end
end
