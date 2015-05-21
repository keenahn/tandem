# A job wrapper to be used with DJ
# This job will run every 5 minutes (as set in clock.rb)
class SendNoReplyMessagesJob  < ActiveJob::Base

  def perform
    Reminder.send_no_reply_messages
  end

end