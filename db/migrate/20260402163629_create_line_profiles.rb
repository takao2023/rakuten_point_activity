class CreateLineProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :line_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :line_user_id
      t.string :display_name
      t.string :picture_url
      t.string :status_message

      t.timestamps
    end
    add_index :line_profiles, :line_user_id, unique: true
  end
end
