class AiAdvisorJob < ApplicationJob
  queue_as :default

  def perform(task_type = 'daily')
    # 全ユーザーに対して処理を実行（API キーがある場合のみ）
    return unless ENV['GEMINI_API_KEY'].present?

    User.find_each do |user|
      begin
        service = AiAdvisorService.new(user)
        if task_type == 'analysis'
          service.analyze_and_reorder
        else
          service.generate_daily_advice
        end
      rescue => e
        Rails.logger.error "AI Advisor failed for user #{user.id} (#{task_type}): #{e.message}"
      end
    end
  end
end
