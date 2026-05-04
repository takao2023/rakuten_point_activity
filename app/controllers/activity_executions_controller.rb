class ActivityExecutionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @activity = PointActivity.find(params[:point_activity_id])
    
    if !@activity.can_execute_now?(current_user)
      # インターバル未達
      next_time = @activity.next_available_time(current_user).in_time_zone('Tokyo').strftime("%H:%M")
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "まだ時間になっていません。次は #{next_time} 以降にプレイ可能です。"
          render turbo_stream: turbo_stream.update("flash-messages", partial: "layouts/flash-message")
        end
        format.html { redirect_back fallback_location: dashboards_path, alert: "まだ時間になっていません。次は #{next_time} 以降にプレイ可能です。" }
      end
    else
      # 実行記録の保存
      execution = ActivityExecution.create!(
        user: current_user, 
        point_activity: @activity
      )
      
      # 活動ログにも記録
      current_user.activity_logs.create!(
        point_activity: @activity,
        action_type: "activity_complete",
        metadata: { execution_id: execution.id }
      )
      
      # ストリークの更新（完了ボタン押下をトリガーにする）
      streak = current_user.user_streak || current_user.create_user_streak
      streak.update_streak!
      
      total = current_user.activity_executions.where(point_activity: @activity).count
      needed = @activity.executions_per_reward || 1
      
      if total > 0 && total % needed == 0
        message = "「#{@activity.full_title}」の完了を報告しました！🎉 #{@activity.reward_points || 1}ポイントを自動獲得しました！"
      else
        message = "「#{@activity.full_title}」の完了を報告しました！ (現在 #{total % needed}/#{needed}回)"
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = message
          render turbo_stream: [
            turbo_stream.update("flash-messages", partial: "layouts/flash-message"),
            turbo_stream.replace("activity_execution_button_#{@activity.id}", partial: "point_activity_targets/activity_execution_button", locals: { activity: @activity, prominent: params[:prominent] == "true" })
          ]
        end
        format.html { redirect_back fallback_location: dashboards_path, notice: message }
      end
    end
  end
end
