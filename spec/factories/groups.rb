FactoryGirl.define do
  factory :group do
    name {Faker::Company.name}
    description {Faker::Company.catch_phrase}
  end
end
