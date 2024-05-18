class PointActivityGetsController < ApplicationController
  before_action :set_point_activity_get, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :redirect_unless_creator, only: [:edit, :update, :destroy]
  
  def index
    @point_activity_gets = current_user.point_activity_gets
    @point_activity_targets = current_user.point_activity_targets
  end
  
  def new
    @point_activity_get = PointActivityGet.new
    @point_activities = PointActivity.all
  end

  def create
    @point_activities = PointActivity.all
    @point_activity_get = PointActivityGet.new(point_activity_get_params)
    if @point_activity_get.save
      redirect_to root_path, notice: 'ポイントが追加されました。'
    else
      redirect_to root_path, alert: 'ポイントの追加に失敗しました。'
    end
  end

  def edit
    @point_activities = PointActivity.all
  end

  def update
    if @point_activity_get.update(point_activity_get_params)
      redirect_to root_path, notice: 'ポイントが更新されました。'
    else
      @point_activities = PointActivity.all
      render :edit
    end
  end
  
  def destroy
    @point_activity_get.destroy
    redirect_to root_path, notice: 'ポイントが削除されました。'
  end

  private

  def point_activity_get_params
    params.require(:point_activity_get).permit(:point_activity_id, :user_id, :get_point)
  end

  def set_point_activity_get
    @point_activity_get = PointActivityGet.find(params[:id])
  end 
  
  def redirect_unless_creator
    redirect_to root_path unless @point_activity_get.user == current_user
  end
end