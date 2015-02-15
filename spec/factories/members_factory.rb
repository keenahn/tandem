FactoryGirl.define do
  factory :member do
    name {Faker::Name.name}
    phone_number { Faker::PhoneNumber.cell_phone }
    active true
  end

end
