class PointActivityGetsController < ApplicationController
  before_action :set_point_activity_get, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :redirect_unless_creator, only: [:edit, :update, :destroy]
  
  def index
    @point_activity_gets = current_user.point_activity_gets
    @point_activity_targets = current_user.point_activity_targets
  end
  
  def new
    @point_activity_get = PointActivityGet.new(point_activity_id: params[:point_activity_id])
    @point_activities = PointActivity.all
    @frame_id = params[:frame_id] || "get_form_#{@point_activity_get.point_activity_id}"
    
    if turbo_frame_request?
      render partial: "inline_form", locals: { point_activity_get: @point_activity_get, frame_id: @frame_id }
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def create
    @point_activities = PointActivity.all
    @point_activity_get = PointActivityGet.new(point_activity_get_params)
    if @point_activity_get.save
      @activity = @point_activity_get.point_activity
      @service = @activity.service
      @card_service = @service
      @new_achievements = Achievement.check_and_award!(current_user)

      respond_to do |format|
        format.turbo_stream do
          @today_date = Time.zone.today
          @target_points = current_user.point_activity_targets.sum(:target_point)
          @today_points = current_user.point_activity_gets.where(created_at: @today_date.beginning_of_day..@today_date.end_of_day).sum(:get_point)
          @month_points = current_user.point_activity_gets.where(created_at: @today_date.beginning_of_month..@today_date.end_of_month).sum(:get_point)
          @user_streak = current_user.user_streak || current_user.create_user_streak
          remaining_points = [@target_points - @month_points, 0].max
          @achievement_chart_data = [
            ['獲得済', @month_points],
            ['残り目標', remaining_points]
          ]
          render :create
        end
        format.html { redirect_to point_activity_targets_path, notice: 'ポイントが追加されました。' }
      end
    else
      @point_activities = PointActivity.all
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("get_form_#{@point_activity_get.point_activity_id}", partial: "form", locals: { point_activity_get: @point_activity_get }) }
      end
    end
  end

  def edit
    @point_activities = PointActivity.all
  end

  def update
    if @point_activity_get.update(point_activity_get_params)
      redirect_to point_activity_targets_path, notice: 'ポイントが更新されました。'
    else
      @point_activities = PointActivity.all
      render :edit
    end
  end
  
  def destroy
    @point_activity_get.destroy
    redirect_to point_activity_targets_path, notice: 'ポイントが削除されました。'
  end

  def bulk_new
    @service = Service.find(params[:service_id])
    if params[:cancel]
      render partial: "bulk_button", locals: { service: @service }
    else
      # そのサービスに属する全活動項目を対象にする
      @activities = @service.point_activities
      @point_activity_get = PointActivityGet.new
      @frame_id = "bulk_form_#{@service.id}"
      render partial: "bulk_form", locals: { service: @service, frame_id: @frame_id }
    end
  end

  def bulk_create
    @service = Service.find(params[:service_id])
    total_point = params[:total_point].to_i
    # そのサービスの全活動項目をターゲットにする
    target_activities = @service.point_activities
    
    # 分配ロジック
    # 重み付け: [n, n-1, ..., 1] の比率で分配
    count = target_activities.size
    weights = (1..count).to_a.reverse
    total_weight = weights.sum
    
    allocated_points = []
    current_sum = 0
    
    weights.each_with_index do |w, i|
      if i == count - 1
        # 最後は残額すべて
        allocated_points << (total_point - current_sum)
      else
        p = (total_point * w.to_f / total_weight).round
        allocated_points << p
        current_sum += p
      end
    end

    PointActivityGet.transaction do
      target_activities.zip(allocated_points).each do |activity, points|
        next if points <= 0
        current_user.point_activity_gets.create!(
          point_activity: activity,
          get_point: points
        )
      end
    end

    # 更新後の表示準備 (create.turbo_stream.erb と共通の変数)
    @card_service = @service
    
    @new_achievements = Achievement.check_and_award!(current_user)

    @today_date = Time.zone.today
    @target_points = current_user.point_activity_targets.sum(:target_point)
    @today_points = current_user.point_activity_gets.where(created_at: @today_date.beginning_of_day..@today_date.end_of_day).sum(:get_point)
    @month_points = current_user.point_activity_gets.where(created_at: @today_date.beginning_of_month..@today_date.end_of_month).sum(:get_point)
    @user_streak = current_user.user_streak || current_user.create_user_streak
    
    remaining_points = [@target_points - @month_points, 0].max
    @achievement_chart_data = [
      ['獲得済', @month_points],
      ['残り目標', remaining_points]
    ]

    respond_to do |format|
      format.turbo_stream { render :create }
      format.html { redirect_to point_activity_targets_path, notice: 'ポイントが一括登録されました。' }
    end
  rescue => e
    logger.error "Bulk create error: #{e.message}"
    respond_to do |format|
      format.html { redirect_to point_activity_targets_path, alert: '一括登録に失敗しました。' }
    end
  end

  private

  def point_activity_get_params
    params.require(:point_activity_get).permit(:point_activity_id, :user_id, :get_point)
  end

  def set_point_activity_get
    @point_activity_get = PointActivityGet.find(params[:id])
  end 
  
  def redirect_unless_creator
    redirect_to point_activity_targets_path unless @point_activity_get.user == current_user
  end
end