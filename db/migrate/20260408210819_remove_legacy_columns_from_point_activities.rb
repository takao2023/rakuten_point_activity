class RemoveLegacyColumnsFromPointActivities < ActiveRecord::Migration[7.1]
  def change
    remove_column :point_activities, :estimated_minutes, :integer
    remove_column :point_activities, :average_points, :integer
  end
end
