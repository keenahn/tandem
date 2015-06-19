module Concerns
  class CheckinsRemindersCreator

    # Runs once an hour thanks to Clockwork and DelayedJob
    def self.create_all_for_hour
      puts "Creating checkins for the day"
      # This is necessary to catch all the different possible timezones

      Pair.active.each{|p|

        # TODO: figure out a way to be safe but also more efficient
        # Perhaps run only on ones that are within an hour or two
        next unless p.local_time.hour == 0 # Run right after midnight, locally
        p.members.each{|m|
          c = Checkin.find_or_initialize_by(member: m, pair: p, local_date: m.local_date)
          c.save
          c.create_or_update_reminder
        }
      }
    end

  end
end
