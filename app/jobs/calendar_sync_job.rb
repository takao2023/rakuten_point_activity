class CalendarSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id = nil)
    # キャンペーン情報を自動生成 (今月と来月分)
    CampaignSchedulerService.schedule_recurring_campaigns(Time.current.month, Time.current.year)
    CampaignSchedulerService.schedule_recurring_campaigns(1.month.from_now.month, 1.month.from_now.year)

    if user_id
      notify_user(User.find(user_id))
    else
      User.find_each { |user| notify_user(user) }
    end
  end

  private

  def notify_user(user)
    # 2日後に開始されるキャンペーンを検索して通知
    target_date = 2.days.from_now.to_date
    campaigns = Campaign.where(start_at: target_date.beginning_of_day..target_date.end_of_day)

    if campaigns.any?
      campaigns.each do |campaign|
        text = "【ポイ活通知】\n明後日から「#{campaign.title}」が始まります！🔥\n準備は良いですか？\n#{campaign.description}"
        
        # 最新のAIアドバイスがあれば追記
        latest_advice = user.ai_advices.order(generated_at: :desc).first
        if latest_advice.present?
          text += "\n\n🤖 執事からの助言：\n#{latest_advice.content}"
        end
        
        # LINE通知
        user.send_line_message(text) if user.line_profile&.line_user_id.present?
      end
    end
  end
end
