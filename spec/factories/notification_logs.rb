FactoryBot.define do
  factory :notification_log do
    user { nil }
    notification_type { "MyString" }
    channel { "MyString" }
    status { "MyString" }
    content { "MyText" }
    error_message { "MyText" }
  end
end
