class AddEstimatedMinutesToPointActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :point_activities, :estimated_minutes, :integer
  end
end
