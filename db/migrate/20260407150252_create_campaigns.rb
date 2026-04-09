class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :campaign_type
      t.datetime :start_at
      t.datetime :end_at
      t.text :description

      t.timestamps
    end
  end
end
