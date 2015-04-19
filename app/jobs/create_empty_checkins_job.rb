# A job wrapper for Checkin.create_empty_checkins to be used with DJ
class CreateEmptyCheckinsJob  < ActiveJob::Base

  def perform
    Checkin.create_empty_checkins
  end

end