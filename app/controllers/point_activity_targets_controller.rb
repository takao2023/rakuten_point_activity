class PointActivityTargetsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_course_selection, only: %i[ index report ]
  before_action :set_point_activity_target, only: %i[ edit update destroy ]
  before_action :redirect_unless_creator, only: %i[ edit update destroy ]
  
  def index
    # 【進捗確認】 広告タップ, ながら, その他
    @point_activities = fetch_activities_by_categories(["広告タップ", "ながら", "その他"])
    @ai_report = current_user.ai_advices.where(advice_type: 'analysis_report').order(generated_at: :desc).first
  end

  def new
    @point_activity = PointActivity.find(params[:point_activity_id])
    @point_activity_target = PointActivityTarget.new(
      point_activity: @point_activity,
      year_month: Date.today.beginning_of_month
    )
  end

  def report
    # 【完了報告】 毎日くじ, ゲームクリア, ミッションクリア
    @point_activities = fetch_activities_by_categories(["毎日くじ", "ゲームクリア", "ミッションクリア"])
    @ai_report = current_user.ai_advices.where(advice_type: 'analysis_report').order(generated_at: :desc).first
  end

  def edit
  end

  def create
    @point_activity_target = current_user.point_activity_targets.build(point_activity_target_params)
    if @point_activity_target.save
      redirect_to point_activity_targets_path, notice: '目標を追加しました！'
    else
      @point_activity = @point_activity_target.point_activity
      flash.now[:alert] = @point_activity_target.errors.full_messages.join(', ')
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
          @point_activities = fetch_activities_by_categories(["広告タップ", "ながら", "その他"])
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

  def fetch_activities_by_categories(category_names)
    target_month = Date.today.beginning_of_month

    # カテゴリ名でフィルタリングし、コースに紐づく案件のみに絞り込む
    current_user.course_point_activities
      .includes(:service, :category, :point_activity_targets)
      .joins(:category)
      .where(categories: { name: category_names })
      .order("point_activities.id ASC")
      .group_by { |a| a.category.name }
  end

  def point_activity_target_params
    params.require(:point_activity_target).permit(:user_id, :point_activity_id, :target_point, :year_month)
  end

  def set_point_activity_target
    @point_activity_target = PointActivityTarget.find(params[:id])
  end 
  
  def redirect_unless_creator
    redirect_to point_activity_targets_path unless @point_activity_target.user == current_user
  end
end
