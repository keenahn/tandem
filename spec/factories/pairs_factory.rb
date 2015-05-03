FactoryGirl.define do
  factory :pair do
    association :group
    association :member_1, factory: :member
    association :member_2, factory: :member
    activity { "meditation" }
    active { true }
    tandem_number { Phoner::Phone.parse(TwilioClient::DEFAULT_FROM_NUMBER + "").to_s }
    time_zone { group.time_zone }  # { ActiveSupport::TimeZone::MAPPING.keys.sample }
    reminder_time_mon { rand(24.hours).seconds.ago }
    reminder_time_tue { reminder_time_mon }
    reminder_time_wed { reminder_time_mon }
    reminder_time_thu { reminder_time_mon }
    reminder_time_fri { reminder_time_mon }
    reminder_time_sat { rand(24.hours).seconds.ago }
    reminder_time_sun { reminder_time_sat }

  end
end
