FactoryGirl.define do
  factory :reminder do
    association :pair
    association :member
    next_reminder_time_utc { Time.now + 2.hour }
    status Reminder::UNSENT
  end

end
