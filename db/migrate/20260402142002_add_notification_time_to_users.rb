class AddNotificationTimeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :notification_time, :integer, default: 19
  end
end
