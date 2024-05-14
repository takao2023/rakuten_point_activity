class PointActivityGetsController < ApplicationController
  before_action :set_point_activity_get, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :redirect_unless_creator, only: [:edit, :update, :destroy]
  
  def index
    @point_activity_gets = PointActivityGet.all
    @point_activity_targets = PointActivityTarget.all
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
  end

  def edit
  end

  def update
    if @point_activity_get.update(point_activity_get_params)
      redirect_to @point_activity_get, notice: 'Point activity get was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @point_activity_get.destroy
    redirect_to root_path, notice: 'Point activity get was successfully destroyed.'
  end

  private

  def point_activity_get_params
    params.require(:point_activity_get).permit(:user_id, :point_activity_id, :get_point)
  end

  def set_point_activity_get
    @point_activity_get = PointActivityGet.find(params[:id])
  end 
  
  def redirect_unless_creator
    redirect_to root_path unless @point_activity_get.user == current_user
  end
end