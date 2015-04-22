module Tandem
  class Utils

    DEFAULT_TIMEZONE = "Pacific Time (US & Canada)"

    # * *Args*    :
    #   - +s+ -> a string representing a date and/or time, but with NO TIMEZONE INFORMATION
    #   - +timezone+ -> a string representing a timezone (or null, in which case we use the default)
    # * *Returns* :
    #   - a Time object of the given time and time zone or nil if a parsing error occurs
    def self.parse_time_in_zone s, timezone = DEFAULT_TIMEZONE
      begin
        Time.use_zone(timezone) {
          a = Time.zone.parse(s)
          return a.in_time_zone(timezone) if a
          nil
        }
      rescue ArgumentError
        nil
      end
    end

  end
end
