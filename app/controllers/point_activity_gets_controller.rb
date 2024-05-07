class PointActivityGetsController < ApplicationController
  def index
    @point_activity_get = PointActivityGet.all
    @point_activity_target = PointActivityTarget.all
  end
  
  def new
    @point_activity_get = PointActivityGet.new
    @point_activities = PointActivity.all
  end

  def create
    @point_activities = PointActivity.all
    @point_activity_get = PointActivityGet.new(point_activity_get_params)
    if @point_activity_get.save
      redirect_to root_path, notice: 'Point activity target was successfully created.'
    else
      flash.now[:alert] = @point_activity_get.errors.full_messages.join(', ')
      render :new
    end
  end

  def show
    @point_activity_get = PointActivityGet.find(params[:id])
  end

  def edit
    @point_activity_get = PointActivityGet.find(params[:id])
  end

  def update
    @point_activity_get = PointActivityGet.find(params[:id])
    if @point_activity_get.update(point_activity_get_params)
      redirect_to @point_activity_get, notice: 'Point activity get was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @point_activity_get = PointActivityGet.find(params[:id])
    @point_activity_get.destroy
    redirect_to root_path, notice: 'Point activity get was successfully destroyed.'
  end

  private

  def point_activity_get_params
    params.require(:point_activity_get).permit(:user_id, :point_activity_id, :get_point)
  end

end