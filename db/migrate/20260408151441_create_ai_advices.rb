class CreateAiAdvices < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_advices do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.string :advice_type
      t.datetime :generated_at

      t.timestamps
    end
  end
end
