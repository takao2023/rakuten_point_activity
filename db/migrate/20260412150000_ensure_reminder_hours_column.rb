class EnsureReminderHoursColumn < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:notification_settings, :reminder_hours)
      add_column :notification_settings, :reminder_hours, :text
    end
  end
end
