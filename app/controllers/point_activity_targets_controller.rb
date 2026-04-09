class PointActivityTargetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_point_activity_target, only: %i[ edit update destroy ]
  before_action :redirect_unless_creator, only: %i[ edit update destroy ]
  
  def index
    @point_activities = fetch_activities_with_targets
    @ai_report = current_user.ai_advices.where(advice_type: 'analysis_report').order(generated_at: :desc).first
  end

  def new
    @point_activities = fetch_activities_by_major_item
    @ai_report = current_user.ai_advices.where(advice_type: 'analysis_report').order(generated_at: :desc).first
  end

  def edit
  end

  def create
    @point_activity_target = current_user.point_activity_targets.build(point_activity_target_params)
    if @point_activity_target.save
      redirect_to point_activity_targets_path, notice: '目標を追加しました！'
    else
      flash.now[:alert] = @point_activity_target.errors.full_messages.join(', ')
      @point_activities = fetch_activities_with_targets
      render :new
    end
  end

  def update
    if @point_activity_target.update(point_activity_target_params)
      redirect_to point_activity_targets_path, notice: '目標を更新しました！'
    else
      render :edit
    end
  end

  def destroy
    @point_activity_target.destroy
    redirect_to point_activity_targets_path, notice: '目標を削除しました！'
  end

  def upsert
    success = PointActivityTargetService.new.upsert_for_current_month(
      user: current_user,
      point_activity_id: params[:point_activity_id],
      target_point: params[:target_point]
    )

    respond_to do |format|
      if success
        format.turbo_stream do
          @point_activities = fetch_activities_with_targets
          flash.now[:notice] = "目標ポイントを更新しました"
        end
        format.html { redirect_to point_activity_targets_path, notice: "目標を更新しました" }
      else
        format.turbo_stream do
          redirect_to point_activity_targets_path, alert: "エラーが発生しました"
        end
        format.html { redirect_to new_point_activity_target_path, alert: "目標の追加に失敗しました。入力値を確認してください。" }
      end
    end
  end

  def ensure_current_month_target
    target_month = Date.today.beginning_of_month
    @point_activity_target = current_user.point_activity_targets.find_or_create_by(
      point_activity_id: params[:point_activity_id],
      year_month: target_month
    ) do |target|
      target.target_point = 0 
    end
    
    if @point_activity_target.persisted?
      redirect_to edit_point_activity_target_path(@point_activity_target)
    else
      redirect_to point_activity_targets_path, alert: "目標レコードの作成に失敗しました：#{@point_activity_target.errors.full_messages.join(', ')}"
    end
  end

  private

  def fetch_activities_with_targets
    # 【ダッシュボード用】 サービス単位で取得
    # カテゴリでグループ化して表示するため、各サービスの代表カテゴリで分ける
    Service.all.includes(point_activities: [:category, :point_activity_targets])
      .group_by { |s| s.point_activities.first&.category&.name || "その他" }
  end

  def fetch_activities_by_major_item
    # 【ポイ活一覧用】 大項目単位で取得（大型カード用）
    target_month = Date.today.beginning_of_month

    PointActivity.includes(:service, :category, :point_activity_targets)
      .joins("LEFT JOIN point_activity_targets ON point_activity_targets.point_activity_id = point_activities.id AND point_activity_targets.user_id = #{current_user.id} AND point_activity_targets.year_month = '#{target_month}'")
      .order("point_activity_targets.priority_score DESC, point_activities.id ASC")
      .group_by { |a| a.category.name }
  end

  def point_activity_target_params
    params.require(:point_activity_target).permit(:user_id, :point_activity_id, :target_point)
  end

  def set_point_activity_target
    @point_activity_target = PointActivityTarget.find(params[:id])
  end 
  
  def redirect_unless_creator
    redirect_to root_path unless @point_activity_target.user == current_user
  end
end
