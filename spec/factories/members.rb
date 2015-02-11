FactoryGirl.define do
  factory :member do
    name {Faker::Name.name}
    phone_number {Faker::PhoneNumber.phone_number}
    active true
  end

end
