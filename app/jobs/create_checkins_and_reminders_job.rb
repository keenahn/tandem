# A job wrapper for Checkin.create_empty_checkins to be used with DJ
class CreateCheckinsAndRemindersJob  < ActiveJob::Base

  def perform
    Concerns::CheckinReminderCreator.create_all_for_hour
  end

end