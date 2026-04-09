class MigrateLineProfilesAndDropColumns < ActiveRecord::Migration[7.1]
  def up
    # 既存のデータを新テーブルに移行 (データの保護)
    User.find_each do |user|
      if user.try(:line_user_id).present?
        LineProfile.find_or_create_by!(
          user: user,
          line_user_id: user.line_user_id
        )
      end
      
      # 古いInteger型の時間をパース
      time_str = user.try(:notification_time) ? format("%02d:00:00", user.notification_time) : "19:00:00"
      
      NotificationSetting.find_or_create_by!(user: user) do |setting|
        setting.morning_reminder = user.try(:notifications_enabled) || false
        setting.morning_reminder_time = "08:00:00"
        setting.evening_summary = user.try(:notifications_enabled) || false
        setting.evening_summary_time = time_str
        setting.notification_channel = 'line'
      end
    end

    # 移行が終わった古いカラムの削除
    remove_column :users, :line_user_id if column_exists?(:users, :line_user_id)
    remove_column :users, :notifications_enabled if column_exists?(:users, :notifications_enabled)
    remove_column :users, :notification_time if column_exists?(:users, :notification_time)
  end

  def down
    add_column :users, :line_user_id, :string unless column_exists?(:users, :line_user_id)
    add_column :users, :notifications_enabled, :boolean, default: true unless column_exists?(:users, :notifications_enabled)
    add_column :users, :notification_time, :integer, default: 19 unless column_exists?(:users, :notification_time)
  end
end
