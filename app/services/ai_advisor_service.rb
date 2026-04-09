class AiAdvisorService
  MODEL_NAME = "gemini-2.0-flash"

  def initialize(user)
    @user = user
    @client = Gemini.new(
      api_key: ENV['GEMINI_API_KEY'],
      model: MODEL_NAME
    )
  end

  def generate_daily_advice
    prompt = build_daily_prompt
    response = @client.generate_content(prompt)
    
    advice_content = response.dig("candidates", 0, "content", "parts", 0, "text")
    
    if advice_content.present?
      @user.ai_advices.create!(
        content: advice_content,
        advice_type: 'daily',
        generated_at: Time.current
      )
    end
  end

  # 本日のメイン機能: 実績に基づくソート順の最適化とレポート生成
  def analyze_and_reorder
    stats_data = fetch_earnings_stats
    prompt = build_analysis_prompt(stats_data)
    
    response = @client.generate_content(prompt)
    raw_text = response.dig("candidates", 0, "content", "parts", 0, "text")
    
    # JSON部分とレポート部分を分離（Gemini が JSON コードブロックで返すことを想定）
    json_match = raw_text.match(/```json\n?(.*?)\n?```/m)
    report_text = raw_text.gsub(/```json\n?(.*?)\n?```/m, "").strip
    
    if json_match
      begin
        scores = JSON.parse(json_match[1])
        update_priority_scores(scores)
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse AI scores: #{e.message}"
      end
    end

    if report_text.present?
      @user.ai_advices.create!(
        content: report_text,
        advice_type: 'analysis_report',
        generated_at: Time.current
      )
    end
  end

  private

  def fetch_earnings_stats
    # 直近30日間、大項目(Level 2)単位の実績を集計
    activities = @user.point_activity_targets.includes(:point_activity)
    
    activities.map do |target|
      pa = target.point_activity
      # 末端項目の合計を取得
      earnings = @user.point_activity_gets
                      .where(point_activity_id: pa.leaf_activities.map(&:id))
                      .where(created_at: 30.days.ago..Time.current)
                      .sum(:get_point)
      
      count = @user.point_activity_gets
                   .where(point_activity_id: pa.leaf_activities.map(&:id))
                   .where(created_at: 30.days.ago..Time.current)
                   .count

      {
        target_id: target.id,
        title: pa.point_activity_title,
        service: pa.parent&.service_name,
        earnings_30d: earnings,
        count_30d: count,
        recommendation_level: pa.recommendation_level
      }
    end
  end

  def build_analysis_prompt(stats_data)
    <<~PROMPT
      あなたは「楽天ポイ活マネジメント」のAIアドバイザーです。
      ユーザーの過去30日の実績データを分析し、ポイ活の優先順位を「金額重視」で再構築してください。

      【分析データ】
      #{stats_data.to_json}

      【依頼内容】
      1. 各項目の推奨度を 1.0 〜 10.0 のスコアで算出してください。獲得金額が多いもの、または効率が良いものを高く評価してください。
      2. ユーザーへの分析レポート（250文字程度）を作成してください。なぜその順位にしたのか、今後は何を重視すべきかを、執事風の丁寧な言葉で伝えてください。

      【出力形式】
      以下の形式で厳密に出力してください。
      ```json
      [
        {"target_id": 1, "score": 9.5},
        {"target_id": 2, "score": 7.0}
      ]
      ```
      （ここにレポート本文を書く）
    PROMPT
  end

  def update_priority_scores(scores)
    scores.each do |s|
      target = @user.point_activity_targets.find_by(id: s["target_id"])
      target.update(priority_score: s["score"]) if target
    end
  end

  def build_daily_prompt
    today = Time.zone.today
    stats = @user.remaining_point_activities
    target_points = @user.point_activity_targets.sum(:target_point)
    current_points = @user.point_activity_gets.where(created_at: today.beginning_of_month..today.end_of_month).sum(:get_point)
    achievement_rate = target_points > 0 ? (current_points.to_f / target_points * 100).round(1) : 0
    upcoming_campaigns = Campaign.where(start_at: today..7.days.from_now).order(:start_at).limit(3)
    
    campaign_info = upcoming_campaigns.map { |c| "- #{c.start_at.strftime('%m/%d')}: #{c.title}" }.join("\n")

    <<~PROMPT
      あなたは「楽天ポイ活マネジメント」というアプリの専属執事です。
      誠実で、ユーザーのポイ活を心から応援し、励ましてくれる性格です。
      以下のユーザーデータに基づき、今日のポイ活のアドバイスを150文字程度で作成してください。

      【ユーザーデータ】
      - 今月の目標ポイント: #{target_points} pt
      - 現在の獲得ポイント: #{current_points} pt
      - 目標達成率: #{achievement_rate}%
      - 今日まだ達成可能なポイ活の数: #{stats.count}件
      - 近日のキャンペーン情報: 
      #{campaign_info.presence || "特になし"}

      【制約事項】
      - 執事らしい丁寧な言葉遣い（〜でございます、〜くださいませ等）を用いること。
      - データの数値を具体的に引用しつつ、現状を褒める、または優しく励ます内容にすること。
      - 出力はアドバイスの本文のみ。余計な挨拶や解説は不要です。
    PROMPT
  end
end
