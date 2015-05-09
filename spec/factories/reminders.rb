FactoryGirl.define do
  factory :reminder do
    association :pair
    association :member
    next_reminder_time_utc "2015-05-02 20:31:25"
    status Reminder::UNSENT
  end

end
