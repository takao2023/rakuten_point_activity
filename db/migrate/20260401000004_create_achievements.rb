class CreateAchievements < ActiveRecord::Migration[7.1]
  def change
    create_table :achievements do |t|
      t.string :name, null: false
      t.string :description
      t.string :icon
      t.string :condition_type
      t.integer :condition_value

      t.timestamps
    end
  end
end
