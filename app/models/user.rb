class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[line]
  has_many :point_activity_targets
  has_many :point_activity_gets
  has_many :daily_tasks, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_one :user_streak, dependent: :destroy

  attribute :selected_course, :integer
  enum selected_course: { super_beginner: 0, beginner: 1, intermediate: 2, advanced: 3 }

  def selected_course_name
    case selected_course
    when 'super_beginner' then '超！超！！初心者コース'
    when 'beginner' then '初心者コース'
    when 'intermediate' then '中級者コース'
    when 'advanced' then '上級者コース'
    else '未設定'
    end
  end

  def course_point_activities
    return PointActivity.none if selected_course.blank?
    
    services = []
    major_items = []

    # 超！超！！初心者コース
    if %w[super_beginner beginner intermediate advanced].include?(selected_course)
      services += ["楽天ウェブ検索", "楽天スーパーポイントスクリーン"]
      major_items += ["ドリームくじ"]
    end

    # 初心者コース
    if %w[beginner intermediate advanced].include?(selected_course)
      services += ["楽天PointMall"]
      major_items += ["ポコポコもぐらたたき", "賢者の難問クイズ"]
    end

    # 中級者コース
    if %w[intermediate advanced].include?(selected_course)
      services += ["R チャンネル", "楽天ポイントモール"]
      major_items += ["幻の海底神殿"]
    end

    # 上級者コース
    if %w[advanced].include?(selected_course)
      services += ["Rakuten Link", "楽天ペイ", "楽天PointClub"]
      major_items += ["スロットパラダイス"]
    end

    PointActivity.joins(:service).where(
      "services.name IN (?) OR point_activities.major_item IN (?)",
      services.uniq, major_items.uniq
    )
  end

  has_many :activity_executions, dependent: :destroy
  has_one :line_profile, dependent: :destroy
  has_one :notification_setting, dependent: :destroy
  has_many :notification_logs, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :ai_advices, dependent: :destroy
  has_many :point_imports, dependent: :destroy

  accepts_nested_attributes_for :notification_setting, update_only: true

  # 現在実行可能な時間管理対象のポイ活を抽出
  def ready_point_activities
    PointActivity.time_managed.select { |pa| pa.can_execute_now?(self) }
  end

  # 今日の未完了ポイ活（1回も実行していない時間管理対象）を抽出
  def remaining_point_activities
    done_ids = activity_executions.where(executed_at: Time.zone.now.all_day).pluck(:point_activity_id).uniq
    PointActivity.time_managed.where.not(id: done_ids)
  end

  # LINE でメッセージを送信
  def send_line_message(text)
    require 'line-bot-api'
    user_id = line_profile&.line_user_id
    return false unless user_id.present?

    client = ::Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_BOT_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_BOT_CHANNEL_TOKEN"]
    }

    message = { type: 'text', text: text }
    client.push_message(user_id, [message])
  end

  # Flex Message を LINE で送信
  def push_flex_message(flex_content)
    require 'line-bot-api'
    user_id = line_profile&.line_user_id
    return false unless user_id.present?

    client = ::Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_BOT_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_BOT_CHANNEL_TOKEN"]
    }

    client.push_message(user_id, [flex_content])
  end

  def self.from_omniauth(auth)
    case auth.provider.to_sym
    when :line
      from_line_omniauth(auth)
    end
  end

  def self.from_line_omniauth(auth)
    profile = LineProfile.find_by(line_user_id: auth.uid)
    
    if profile.present?
      user = profile.user
    else
      email = auth.info.email || "#{auth.uid}@line.me"
      user = User.where(email: email).first_or_create do |u|
        u.password = Devise.friendly_token[0, 20]
      end
      
      user.create_line_profile(
        line_user_id: auth.uid,
        display_name: auth.info.name,
        picture_url: auth.info.image
      )
    end
    
    ensure_notification_setting(user)
    user
  end

  def self.ensure_notification_setting(user)
    unless user.notification_setting.present?
      user.create_notification_setting(
        morning_reminder: true,
        morning_reminder_time: "08:00:00",
        reminder_hours: [8],
        evening_summary: true,
        evening_summary_time: "21:00:00",
        campaign_alert: true,
        achievement_alert: true,
        streak_warning: true,
        notification_channel: 'line'
      )
    end
  end
end
