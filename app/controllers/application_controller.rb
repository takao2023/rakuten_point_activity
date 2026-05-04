class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [
      notification_setting_attributes: [:id, :morning_reminder, :morning_reminder_time, reminder_hours: []]
    ])
  end

  # ログイン後はダッシュボードへリダイレクト
  def after_sign_in_path_for(resource)
    dashboards_path
  end

  # ログアウト後はランディングページ（トップ）へリダイレクト
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def require_course_selection
    if user_signed_in? && current_user.selected_course.blank?
      redirect_to courses_path, notice: "ポイ活を始めるには、まずコースを選択してください！"
    end
  end
end
