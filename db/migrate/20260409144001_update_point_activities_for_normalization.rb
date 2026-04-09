class UpdatePointActivitiesForNormalization < ActiveRecord::Migration[7.1]
  def change
    # 外部キーの追加
    add_reference :point_activities, :service, foreign_key: true
    add_reference :point_activities, :category, foreign_key: true
    
    # 新しい項目名の追加 (大項目、小項目)
    add_column :point_activities, :major_item, :string
    add_column :point_activities, :small_item, :string
    
    # オススメ度のデフォルト値を 1 (3段階評価) に変更
    change_column_default :point_activities, :recommendation_level, 1
  end
end
