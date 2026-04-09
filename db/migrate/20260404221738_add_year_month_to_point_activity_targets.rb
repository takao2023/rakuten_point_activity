class AddYearMonthToPointActivityTargets < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:point_activity_targets, :year_month)
      add_column :point_activity_targets, :year_month, :date
    end

    reversible do |dir|
      dir.up do
        PointActivityTarget.update_all(year_month: Date.today.beginning_of_month)
      end
    end

    add_index :point_activity_targets, [:user_id, :point_activity_id, :year_month], unique: true, name: "index_pat_on_user_activity_month"
  end
end
