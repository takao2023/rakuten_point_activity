class CreateNormalizationTables < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :categories, :code, unique: true

    create_table :services do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :platform
      t.string :official_url
      t.timestamps
    end
    add_index :services, :code, unique: true
  end
end
