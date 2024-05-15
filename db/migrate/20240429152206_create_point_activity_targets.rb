class CreatePointActivityTargets < ActiveRecord::Migration[6.1]
  def change
    create_table :point_activity_targets do |t|
      t.bigint :user_id, null: false, foreign_key: true
      t.references :point_activity, null: false, foreign_key: true
      t.integer :target_point

      t.timestamps
    end
  end
end
