class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [
      notification_setting_attributes: [:id, :morning_reminder, :morning_reminder_time]
    ])
  end
end
