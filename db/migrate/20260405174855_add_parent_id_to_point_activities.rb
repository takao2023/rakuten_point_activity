class AddParentIdToPointActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :point_activities, :parent_id, :integer
    add_index :point_activities, :parent_id
  end
end
