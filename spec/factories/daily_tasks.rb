FactoryBot.define do
  factory :daily_task do
    user { nil }
    point_activity { nil }
    task_date { "2026-04-02" }
    completed { false }
    completed_at { "2026-04-02 03:56:11" }
  end
end
