require "clockwork"
require "./config/boot.rb"
require "./config/environment.rb"

# clockwork clock.rb

module Clockwork
  # handler receives the time when job is prepared to run in the 2nd argument
  handler do |job, time|
    puts "Handling #{job} at #{time}"
  end

  every(1.hour, "Create Empty Checkins", at: "**:01"){
    CreateCheckinsAndRemindersJob.perform_later
  }


  mutliples_of_five = (0..11).to_a.map{|x| "**:#{(x*5).to_s.rjust(2, '0')}"}


  every(1.hour, "Send 'No Reply' messages", at: []){
    SendNoReplyMessagesJob.perform_later
  }

  every(Reminder::DEFAULT_WINDOW.minutes, "Send reminders"){
    SendRemindersJob.perform_later
  }

end