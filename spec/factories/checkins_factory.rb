FactoryGirl.define do
  factory :checkin do
    association :pair
    association :member
    local_date { member.local_date }
    done_at { nil }
  end

end
