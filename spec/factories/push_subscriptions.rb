FactoryBot.define do
  factory :push_subscription do
    endpoint { "MyString" }
    p256dh { "MyString" }
    auth { "MyString" }
    user { nil }
  end
end
