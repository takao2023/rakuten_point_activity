FactoryBot.define do
  factory :notification_setting do
    user { nil }
    morning_reminder { false }
    morning_reminder_time { "2026-04-03 01:36:31" }
    evening_summary { false }
    evening_summary_time { "2026-04-03 01:36:31" }
    campaign_alert { false }
    achievement_alert { false }
    streak_warning { false }
    notification_channel { "MyString" }
  end
end
