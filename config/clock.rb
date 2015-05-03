require "clockwork"
require "./config/boot.rb"
require "./config/environment.rb"

module Clockwork
  # handler receives the time when job is prepared to run in the 2nd argument
  handler do |job, time|
    puts "Handling #{job} at #{time}"
  end

  every(1.hour, "Create Empty Checkins", at: "**:43"){
    CreateCheckinsAndRemindersJob.perform_later
    # Delayed::Job.enqueue(CreateEmptyCheckinsJob.new)
  }

  # every(3.minutes, "less.frequent.job")
  # every(1.hour, "hourly.job")

  # every(1.day, "midnight.job", :at => "00:00")
end