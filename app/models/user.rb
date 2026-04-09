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

  has_one :line_profile, dependent: :destroy
  has_one :notification_setting, dependent: :destroy
  has_many :notification_logs, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :ai_advices, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements

  accepts_nested_attributes_for :notification_setting, update_only: true

  # 今月まだ達成していない有効な（目標 > 0）ポイ活を抽出
  def remaining_point_activities
    target_month = Date.today.beginning_of_month
    target_ids = point_activity_targets.where(year_month: target_month).where("target_point > 0").pluck(:point_activity_id)
    done_ids = point_activity_gets.where(created_at: Time.zone.now.all_day).pluck(:point_activity_id)
    
    pending_ids = target_ids - done_ids
    PointActivity.where(id: pending_ids)
  end

  # LINE でメッセージを送信
  def send_line_message(text)
    user_id = line_profile&.line_user_id
    return false unless user_id.present?

    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    message = { type: 'text', text: text }
    client.push_message(user_id, message)
  end

  # Flex Message を LINE で送信
  def push_flex_message(flex_content)
    user_id = line_profile&.line_user_id
    return false unless user_id.present?

    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    client.push_message(user_id, flex_content)
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
