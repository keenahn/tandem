module Tandem
  class Utils

    # * *Args*    :
    #   - +s+ -> a string representing a date and/or time, but with NO TIMEZONE INFORMATION
    #   - +timezone+ -> a string representing a timezone (or null, in which case we use the default)
    # * *Returns* :
    #   - a Time object of the given time and time zone or nil if a parsing error occurs
    def self.parse_time_in_zone s, timezone = Tandem::Consts::DEFAULT_TIMEZONE
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

    def self.short_time t
      return nil unless t
      t.strftime(Tandem::Consts::SHORT_TIME_FORMAT).strip
    end

    def self.short_time_24 t
      return nil unless t
      t.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT)
    end

    def self.short_date d, timezone = DEFAULT_TIMEZONE
      d.in_time_zone(timezone).strftime('%m/%d/%y')
    end

    def self.long_date d, timezone = DEFAULT_TIMEZONE
      d.in_time_zone(timezone).strftime('%Y-%m-%d')
    end

    def self.text_date d, timezone = DEFAULT_TIMEZONE
      d = d.in_time_zone(timezone)
      d.strftime("%B #{d.day.ordinalize}, %Y")
    end

    def self.text_date_with_weekday d, timezone = DEFAULT_TIMEZONE
      d = d.in_time_zone(timezone)
      d.strftime("%A, %B #{d.day.ordinalize}")
    end

    def self.long_date_time d, timezone = DEFAULT_TIMEZONE
      d.in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S')
    end

  end
end
