class UpdatePointActivitySchema < ActiveRecord::Migration[7.1]
  def change
    add_column :point_activities, :service_name, :string
    add_column :point_activities, :platform, :string
    add_column :point_activities, :content_category, :string
    add_column :point_activities, :frequency, :string
    add_column :point_activities, :recommendation_level, :integer, default: 0
  end
end
