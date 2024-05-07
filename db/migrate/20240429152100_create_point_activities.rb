class CreatePointActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :point_activities do |t|
      t.string :point_activity_title

      t.timestamps
    end
  end
end
