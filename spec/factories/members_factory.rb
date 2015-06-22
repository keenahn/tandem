FactoryGirl.define do
  factory :member do
    name { Faker::Name.name }
    phone_number { Phoner::Phone.parse(Faker::PhoneNumber.cell_phone).to_s }
    active true
    gender { ["male", "female", "neutral"].sample }
  end
end
