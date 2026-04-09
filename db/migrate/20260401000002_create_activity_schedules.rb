class CreateActivitySchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_schedules do |t|
      t.references :point_activity, null: false, foreign_key: true
      t.string :frequency
      t.json :days_of_week
      t.time :available_from
      t.time :available_until
      t.integer :estimated_minutes
      t.integer :estimated_points

      t.timestamps
    end
  end
end
