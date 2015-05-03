FactoryGirl.define do
  factory :member do
    name { Faker::Name.name }
    phone_number { Phoner::Phone.parse(Faker::PhoneNumber.cell_phone).to_s }
    active true
  end
end
