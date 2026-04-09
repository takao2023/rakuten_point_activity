class CreateNotificationLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type
      t.string :channel
      t.string :status
      t.text :content
      t.text :error_message

      t.timestamps
    end
  end
end
