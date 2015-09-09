module Concerns
  class CheckinsRemindersCreator

    # Runs once an hour thanks to Clockwork and DelayedJob
    def self.create_all_for_hour
      # puts "Creating checkins for the day"
      # This is necessary to catch all the different possible timezones

      Pair.active.each{|p|
        # TODO: figure out a way to be safe but also more efficient
        # Perhaps run only on ones that are within an hour or two
        p.members.each{|m|
          next unless m.local_time.hour == 0 # Run right after midnight, locally
          m.create_checkin_and_reminder(p)
        }

      }
    end

  end
end
