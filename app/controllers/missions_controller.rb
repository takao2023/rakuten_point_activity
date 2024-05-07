# app/controllers/missions_controller.rb

class MissionsController < ApplicationController
  def new
    @mission = Mission.new
  end

  def create
    @mission = Mission.new(mission_params)
    if @mission.save
      redirect_to @mission, notice: 'Mission was successfully created.'
    else
      render :new
    end
  end

  private

  def mission_params
    params.require(:mission).permit(:user_id, :content, :penalty, :deadline)
  end
end
