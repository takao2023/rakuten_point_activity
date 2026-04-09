class CreateUserStreaks < ActiveRecord::Migration[7.1]
  def change
    create_table :user_streaks do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :current_streak, default: 0
      t.integer :longest_streak, default: 0
      t.date :last_completed_date

      t.timestamps
    end
  end
end
