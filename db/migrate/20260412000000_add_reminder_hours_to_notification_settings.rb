class AddReminderHoursToNotificationSettings < ActiveRecord::Migration[7.1]
  def change
    # 複数のリマインド時間を JSON 配列で保持するカラムを追加
    # 例: [8, 11, 18, 22] → 8時, 11時, 18時, 22時に通知
    add_column :notification_settings, :reminder_hours, :text, default: "[]"
  end
end
