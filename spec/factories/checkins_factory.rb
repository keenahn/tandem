FactoryGirl.define do
  factory :checkin do
    association :pair
    association :member
    local_date { Time.now.to_date }
    done_at { nil }
  end

end
