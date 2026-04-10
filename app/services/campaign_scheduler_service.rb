class CampaignSchedulerService
  def self.schedule_recurring_campaigns(month = Time.current.month, year = Time.current.year)
    service = new(month, year)
    service.schedule_five_zero_days
    service.schedule_wonderful_day
    service.schedule_market_day
  end

  def initialize(month, year)
    @month = month
    @year = year
  end

  # 0と5の付く日を自動生成
  def schedule_five_zero_days
    days = [5, 10, 15, 20, 25, 30]
    days.each do |day|
      begin
        date = Date.new(@year, @month, day)
        title = "毎月0と5の付く日はポイント4倍"
        
        Campaign.find_or_create_by!(
          campaign_type: 'recurring',
          start_at: date.beginning_of_day,
          end_at: date.end_of_day
        ) do |c|
          c.title = title
          c.description = "楽天カード利用でポイント還元率がアップする定期キャンペーンです。要エントリー。"
        end
      rescue Date::Error
        # 30日がない月（2月など）はスキップ
        next
      end
    end
  end

  # 毎月1日：ワンダフルデー
  def schedule_wonderful_day
    date = Date.new(@year, @month, 1)
    campaign = Campaign.find_or_create_by!(
      campaign_type: 'recurring',
      start_at: date.beginning_of_day,
      end_at: date.end_of_day
    )
    campaign.update!(
      title: "ワンダフルデー",
      description: "全ショップポイント3倍！リピート購入はさらにお得になる、月初めのビッグチャンスです。"
    )
  end

  # 毎月18日：ご愛顧感謝デー（いちばの日）
  def schedule_market_day
    date = Date.new(@year, @month, 18)
    Campaign.find_or_create_by!(
      campaign_type: 'recurring',
      start_at: date.beginning_of_day,
      end_at: date.end_of_day
    ) do |c|
      c.title = "毎月18日はご愛顧感謝デー"
      c.description = "「いちばの日」として、ダイヤモンド会員ならポイント4倍など、会員ランクに応じて還元率がアップします。"
    end
  end

  # 他のキャンペーン（マラソン等）については将来的に取得APIなどを検討
end
