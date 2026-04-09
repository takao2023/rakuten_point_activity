class AddColumnsToPointActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :point_activities, :description, :string
    add_column :point_activities, :detail_description, :text
    add_column :point_activities, :official_url, :string
    add_column :point_activities, :strategy_url, :string
    add_column :point_activities, :average_points, :integer
  end
end
