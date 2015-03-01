FactoryGirl.define do
  factory :user, aliases: [:owner] do
    email { Faker::Internet.email }
    password "12345678"
    password_confirmation { "12345678" }
    time_zone { "Eastern Time (US & Canada)" }
  end
end
