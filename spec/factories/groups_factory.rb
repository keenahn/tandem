FactoryGirl.define do
  factory :group do
    owner
    name { Faker::Company.name }
    description { Faker::Company.catch_phrase }

    factory :group_with_members do
      # members_count is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        members_count 10
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |group, evaluator|
        (0..(evaluator.members_count - 1)).each do
          FactoryGirl.create(:group_membership,  group: group)
        end
        members = group.members.all.shuffle
        half = evaluator.members_count / 2 - 1
        (0..half).each do |i|
          FactoryGirl.create(:pair,  group: group, member_1: members[i], member_2: members[i + half + 1])
        end
      end # close after(:create)
    end # close :group_with_members
  end # close :group
end
