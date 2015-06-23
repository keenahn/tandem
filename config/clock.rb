require "clockwork"
require "./config/boot.rb"
require "./config/environment.rb"

# clockwork clock.rb

module Clockwork
  # handler receives the time when job is prepared to run in the 2nd argument
  handler do |job, time|
    puts "Handling #{job} at #{time}"
  end

  every(1.hour, "Create Empty Checkins", at: "**:02"){
    CreateCheckinsAndRemindersJob.perform_later
  }

  #
  # DEFAULT_WINDOW  = 5

  # # How much after the initial reminder to send the no_reply message
  # NO_REPLY_MINUTES = 10

  # # How often we'll be sending the no_reply messages
  # NO_REPLY_WINDOW = 5

  no_reply_multiples = (0..(60/Reminder::NO_REPLY_WINDOW - 1)).to_a.map{ |x|
    "**:#{(x*Reminder::NO_REPLY_WINDOW).to_s.rjust(2, '0')}"
  }

  reminder_multiples = (0..(60/Reminder::DEFAULT_WINDOW - 1)).to_a.map{ |x|
    "**:#{(x*Reminder::DEFAULT_WINDOW).to_s.rjust(2, '0')}"
  }

  every(1.hour, "Send 'No Reply' messages", at: no_reply_multiples){
    SendNoReplyMessagesJob.perform_later
  }

  every(1.hour, "Send reminders", at: reminder_multiples){
    SendRemindersJob.perform_later
  }

end