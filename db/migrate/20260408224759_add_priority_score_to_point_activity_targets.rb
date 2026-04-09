class AddPriorityScoreToPointActivityTargets < ActiveRecord::Migration[7.1]
  def change
    add_column :point_activity_targets, :priority_score, :float
  end
end
