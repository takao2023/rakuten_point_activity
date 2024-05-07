class PointActivityTargetsController < ApplicationController
  def index
    @point_activity_target = PointActivityTarget.all
    @point_activity_targets_month = PointActivityTarget.where(created_at: Time.zone.today.beginning_of_month..Time.zone.today.end_of_month).group(:point_activity_id).select("point_activity_id, SUM(target_point) as total_target_point")
    @point_activity_get = PointActivityGet.all
    @point_activities = PointActivity.all

    @point_activity_get_today = PointActivityGet.where(created_at: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day)
    @point_activity_get_this_week = PointActivityGet.where(created_at: Time.zone.today.beginning_of_week..Time.zone.today.end_of_week).group(:point_activity_id).select("point_activity_id, SUM(get_point) as total_get_point")
    @point_activity_get_this_month = PointActivityGet.where(created_at: Time.zone.today.beginning_of_month..Time.zone.today.end_of_month).group(:point_activity_id).select("point_activity_id, SUM(get_point) as total_get_point")
  end

  def new
    @point_activity_target = PointActivityTarget.new
    @point_activities = PointActivity.all
  end

  def create
    @point_activities = PointActivity.all
    @point_activity_target = PointActivityTarget.new(point_activity_target_params)
    if @point_activity_target.save
      redirect_to root_path, notice: 'Point activity target was successfully created.'
    else
      flash.now[:alert] = @point_activity_target.errors.full_messages.join(', ')
      render :new
    end
  end

  def show
    @point_activity_target = PointActivityTarget.find(params[:id])
  end

  def edit
    @point_activity_target = PointActivityTarget.find(params[:id])
  end

  def update
    @point_activity_target = PointActivityTarget.find(params[:id])
    if @point_activity_target.update(point_activity_target_params)
      redirect_to root_path, notice: 'Point activity target was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @point_activity_target = PointActivityTarget.find(params[:id])
    @point_activity_target.destroy
    redirect_to root_path, notice: 'Point activity target was successfully destroyed.'
  end

  private

  def point_activity_target_params
    params.require(:point_activity_target).permit(:user_id, :point_activity_id, :target_point)
  end

end
