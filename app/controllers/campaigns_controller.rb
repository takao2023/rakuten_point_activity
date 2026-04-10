class CampaignsController < ApplicationController
  before_action :authenticate_user!

  def index
    @today = Date.current
    @current_month_days = (@today.beginning_of_month..@today.end_of_month).to_a
    
    month_time_range = @today.beginning_of_month.beginning_of_day..@today.end_of_month.end_of_day
    
    @campaigns = Campaign.order(start_at: :asc)
                        .where(start_at: month_time_range)
    
    @grouped_campaigns = @campaigns.group_by { |c| c.start_at.strftime("%Y年%m月") }
    
    # カレンダー描画用に日付ごとのキャンペーン有無をマッピング
    @campaign_days = @campaigns.map { |c| c.start_at.to_date }.uniq

    # 日別の累計獲得ポイントを算出してハッシュ化 { Date => points }
    # タイムゾーンのズレを防ぐため、Ruby 側で集計 (created_at は Rails が自動で JST に変換済み)
    @daily_points = current_user.point_activity_gets
                      .where(created_at: month_time_range)
                      .to_a
                      .group_by { |get| get.created_at.to_date }
                      .transform_values { |gets| gets.sum(&:get_point) }
  end
end
