class CreateDailyTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :point_activity, null: false, foreign_key: true
      t.date :task_date, null: false
      t.boolean :completed, default: false
      t.datetime :completed_at

      t.timestamps
    end
    add_index :daily_tasks, [:user_id, :task_date, :point_activity_id], unique: true, name: 'idx_daily_tasks_uniqueness'
  end
end
