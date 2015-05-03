module Concerns
  module LocalTimeMixin
    extend ActiveSupport::Concern

    # Requires that the class including this mixin has a "time_zone" function

    # TODO: unit tests
    def local_time
      Time.now.in_time_zone(time_zone)
    end

    # TODO: unit tests
    def local_date
      local_time.to_date
    end
  end
end