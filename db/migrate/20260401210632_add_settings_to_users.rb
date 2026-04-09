class AddSettingsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :notifications_enabled, :boolean, default: true
    add_column :users, :line_user_id, :string
  end
end
