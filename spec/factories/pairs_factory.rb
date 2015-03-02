FactoryGirl.define do
  factory :pair do
    association :group
    association :member_1, factory: :member
    association :member_2, factory: :member
    activity { "meditation" }
  end
end
