class CreateNotificationSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :morning_reminder, default: true
      t.time :morning_reminder_time, default: "08:00"
      t.boolean :evening_summary, default: true
      t.time :evening_summary_time, default: "21:00"
      t.boolean :campaign_alert, default: true
      t.boolean :achievement_alert, default: true
      t.boolean :streak_warning, default: true
      t.string :notification_channel, default: "line"

      t.timestamps
    end
  end
end
