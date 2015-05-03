# A job wrapper to be used with DJ
# This job will run every minute (as set in clock.rb)
class SendRemindersJob  < ActiveJob::Base

  def perform
    Reminder.send_reminders
  end

end