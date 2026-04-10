class CampaignsController < ApplicationController
  before_action :authenticate_user!

  def index
    @today = Date.current
    @current_month_days = (@today.beginning_of_month..@today.end_of_month).to_a
    
    @campaigns = Campaign.order(start_at: :asc)
                        .where('start_at >= ?', @today.beginning_of_month.beginning_of_day)
    
    @grouped_campaigns = @campaigns.group_by { |c| c.start_at.strftime("%Y年%m月") }
    
    # カレンダー描画用に日付ごとのキャンペーン有無をマッピング
    @campaign_days = @campaigns.where(start_at: @today.all_month).map { |c| c.start_at.to_date }.uniq

    # 日別の累計獲得ポイントを算出してハッシュ化 { Date => points }
    # タイムゾーンのズレを防ぐため、Ruby 側で集計 (created_at は Rails が自動で JST に変換済み)
    @daily_points = current_user.point_activity_gets
                      .where(created_at: @today.all_month)
                      .to_a
                      .group_by { |get| get.created_at.to_date }
                      .transform_values { |gets| gets.sum(&:get_point) }
  end
end
