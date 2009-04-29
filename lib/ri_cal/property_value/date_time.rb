require 'date'
module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar CalAddress property value
    # which is defined in RFC 2445 section 4.3.5 pp 35-37
    class DateTime < PropertyValue

      attr_reader :timezone #:nodoc:

      def self.or_date(parent, line) # :nodoc:
        if /T/.match(line[:value] || "")
          new(parent, line)
        else
          PropertyValue::Date.new(parent, line)
        end
      end

      def self.debug # :nodoc:
        @debug
      end

      def self.default_tzid # :nodoc:
        @default_tzid ||= "UTC"
      end

      # Set the default tzid to be used when instantiating an instance from a ruby object
      # see RiCal::PropertyValue::DateTime.from_time
      #
      # The parameter tzid is a string value to be used for the default tzid, a value of 'none' will cause
      # values with NO timezone to be produced, which will be interpreted by iCalendar as floating times
      # i.e. they are interpreted in the timezone of each client. Floating times are typically used
      # to represent events which are 'repeated' in the various time zones, like the first hour of the year.
      def self.default_tzid=(tzid)
        @default_tzid = value
      end

      def self.default_tzid_hash # :nodoc:
        if default_tzid.to_s == 'none'
          {}
        else
          {'TZID' => default_tzid}
        end
      end

      def self.debug= val # :nodoc:
        @debug = val
      end

      include Comparable

      #  if end_time is nil => nil
      #  otherwise convert end_time to a DateTime and compute the difference
      def duration_until(end_time) # :nodoc:
        end_time  && RiCal::PropertyValue::Duration.from_datetimes(parent_component, to_datetime, end_time.to_datetime)
      end

      # Double-dispatch method for subtraction.
      def subtract_from_date_time_value(dtvalue) #:nodoc:
        RiCal::PropertyValue::Duration.from_datetimes(parent_component, to_datetime,dtvalue.to_datetime)
      end

      # Double-dispatch method for addition.
      def add_to_date_time_value(date_time_value) #:nodoc:
        raise ArgumentError.new("Cannot add #{date_time_value} to #{self}")
      end

      # Return the difference between the receiver and other
      #
      # The parameter other should be either a RiCal::PropertyValue::Duration or a RiCal::PropertyValue::DateTime
      #
      # If other is a Duration, the result will be a DateTime, if it is a DateTime the result will be a Duration
      def -(other)
        other.subtract_from_date_time_value(self)
      end

      # Return the sum of the receiver and duration
      #
      # The parameter other duration should be  a RiCal::PropertyValue::Duration
      #
      # The result will be an RiCal::PropertyValue::DateTime
      def +(duration)
        duration.add_to_date_time_value(self)
      end

      def inspect # :nodoc:
        "#{@date_time_value}:#{tzid}"
      end

      # Returns the value of the receiver as an RFC 2445 iCalendar string
      def value
        if @date_time_value
          @date_time_value.strftime("%Y%m%dT%H%M%S#{tzid == "UTC" ? "Z" : ""}")
        else
          nil
        end
      end

      # Set the value of the property to val
      #
      # val may be either:
      #
      # * A string which can be parsed as a DateTime
      # * A Time instance
      # * A Date instance
      # * A DateTime instance
      def value=(val) # :nodoc:
        case val
        when nil
          @date_time_value = nil
        when String
          self.tzid = 'UTC' if val =~/Z/
          @date_time_value = ::DateTime.parse(val)
        when ::DateTime
          @date_time_value = val
        when ::Date, ::Time
          @date_time_value = ::DateTime.parse(val.to_s)
        end
      end

      # determine if the object acts like an activesupport enhanced time, and return it's timezone if it has one.
      def self.object_time_zone(object)
        activesupport_time = object.acts_like_time? rescue nil
        activesupport_time && object.time_zone rescue nil
      end

      def init_timezone(time_zone) #:nodoc:
        @timezone = time_zone
        self
      end

      # Return the receiver if it has a floating time zone already,
      # otherwise return a DATETIME property with the same time as the receiver but with a floating time zone
      def with_floating_timezone
        if @time_zone == FloatingTimezone
          self
        else
          @date_time_value.with_floating_timezone.to_ri_cal_date_time_value
        end
      end

      def self.params_for_timezone(time_zone) #:nodoc:
        if time_zone == FloatingTimezone
          {}
        else
          {'TZID' => time_zone.identifier, 'X-RICAL-TZSOURCE' => 'TZINFO'}
        end
      end

      def self.convert(parent, ruby_object) # :nodoc:
        time_zone = object_time_zone(ruby_object)
        if time_zone
          result = new(
          parent,
          :params => params_for_timezone(time_zone),
          :value => ruby_object.strftime("%Y%m%d%H%M%S")
          )
          result.init_timezone(time_zone)
          result
        else
          ruby_object.to_ri_cal_date_or_date_time_value.for_parent(parent)
        end
      end

      def self.from_string(string) # :nodoc:
        if string.match(/Z$/)
          new(nil, :value => string, :tzid => 'UTC')
        else
          new(nil, :value => string)
        end
      end

      # Create an instance of RiCal::PropertyValue::DateTime representing a Ruby Time or DateTime
      # If the ruby object has been extended by ActiveSupport to have a time_zone method, then
      # the timezone will be used as the TZID parameter.
      #
      # Otherwise the class level default tzid will be used.
      # == See
      # * RiCal::PropertyValue::DateTime.default_tzid
      # * RiCal::PropertyValue::DateTime#object_time_zone
      def self.from_time(time_or_date_time)
        time_zone = object_time_zone(time_or_date_time)
        if time_zone
          new(
          :params => {'TZID' => time_zone.identifier, 'X-RICAL-TZSOURCE' => 'TZINFO'},
          :value => time_or_date_time.strftime("%Y%m%d%H%M%S")
          )
        else
          new(nil, :value => time_or_date_time.strftime("%Y%m%dT%H%M%S"), :params => default_tzid_hash)
        end
      end
      
      
      def for_parent(parent)
        if parent_component.nil?
          @parent_component = parent
          self
        elsif parent == parent_component
          self
        else
          DateTime.new(parent, :value => @date_time_value, :params => params, :tzid => tzid)
        end
      end
      
      # Return the timezone id of the receiver, or nil if it is a floating time
      def tzid
        @tzid
      end

      def tzid=(string)
        @tzid = string
      end

      def visible_params # :nodoc:
        result = {"VALUE" => "DATE-TIME"}.merge(params)
        if has_local_timezone?
          result['TZID'] = tzid
        else
          result.delete('TZID')
        end
        result
      end

      def params=(value)
        @params = value.dup
        if params_timezone = params['TZID']
          if params_timezone == 'UTC'
          end
          @tzid = params_timezone
        end
      end

      def compute_change(d, options) # :nodoc:
        ::DateTime.civil(
        options[:year]  || d.year,
        options[:month] || d.month,
        options[:day]   || d.day,
        options[:hour]  || d.hour,
        options[:min]   || (options[:hour] ? 0 : d.min),
        options[:sec]   || ((options[:hour] || options[:min]) ? 0 : d.sec),
        options[:offset]  || d.offset,
        options[:start]  || d.start
        )
      end

      def compute_advance(d, options) # :nodoc:
        d = d >> options[:years] * 12 if options[:years]
        d = d >> options[:months]     if options[:months]
        d = d +  options[:weeks] * 7  if options[:weeks]
        d = d +  options[:days]       if options[:days]
        datetime_advanced_by_date = compute_change(@date_time_value, :year => d.year, :month => d.month, :day => d.day)
        seconds_to_advance = (options[:seconds] || 0) + (options[:minutes] || 0) * 60 + (options[:hours] || 0) * 3600
        seconds_to_advance == 0 ? datetime_advanced_by_date : datetime_advanced_by_date + Rational(seconds_to_advance.round, 86400)
      end

      def advance(options) # :nodoc:
        PropertyValue::DateTime.new(parent_component,
                                    :value => compute_advance(@date_time_value, options),
                                    :tzid => tzid,
                                    :params =>(params ? params.dup : nil)
        )
      end

      def change(options) # :nodoc:
        PropertyValue::DateTime.new(parent_component,
                                    :value => compute_change(@date_time_value, options),
                                    :tzid => tzid,
                                    :params => (params ? params.dup : nil)
        )
      end

      def self.civil(year, month, day, hour, min, sec, offset, start, params) # :nodoc:
        PropertyValue::DateTime.new(parent_component,
                                   :value => ::DateTime.civil(year, month, day, hour, min, sec, offset, start),
                                   :tzid => tzid,
                                   :params =>(params ? params.dup : nil)
        )
      end

      def change_sec(new_sec) #:nodoc:
        PropertyValue::DateTime.civil(self.year, self.month, self.day, self.hour, self.min, sec, self.offset, self.start, params)
      end

      def change_min(new_min) #:nodoc:
        PropertyValue::DateTime.civil(self.year, self.month, self.day, self.hour, new_min, self.sec, self.offset, self.start, params)
      end

      def change_hour(new_hour) #:nodoc:
        PropertyValue::DateTime.civil(self.year, self.month, self.day, new_hour, self.min, self.sec, self.offset, self.start, params)
      end

      def change_day(new_day) #:nodoc:
        PropertyValue::DateTime.civil(self.year, self.month, new_day, self.hour, self.min, self.sec, self.offset, self.start, params)
      end

      def change_month(new_month) #:nodoc:
        PropertyValue::DateTime.civil(self.year, new_month, self.day, self.hour, self.min, self.sec, self.offset, self.start, params)
      end

      def change_year(new_year) #:nodoc:
        PropertyValue::DateTime.civil(new_year, self.month, self.day, self.hour, self.min, self.sec, self.offset, self.start, params)
      end

      # Compare the receiver with another object which must respond to the to_datetime message
      # The comparison is done using the Ruby DateTime representations of the two objects
      def <=>(other)
        @date_time_value <=> other.to_datetime
      end

      # Return a DATE-TIME property representing the receiver on a different day (if necessary) so that
      # the result is within the 7 days starting with date
      def in_week_starting?(date)
        wkst_jd = date.jd
        @date_time_value.jd.between?(wkst_jd, wkst_jd + 6)
      end

      # Return a DATE-TIME property representing the receiver on a different day (if necessary) so that
      # the result is the first day of the ISO week starting on the wkst day containing the receiver.
      def at_start_of_week_with_wkst(wkst)
        date = @date_time_value.start_of_week_with_wkst(wkst)
        change(:year => date.year, :month => date.month, :day => date.day)
      end

      # Determine if the receiver and other are in the same month
      def in_same_month_as?(other)
        [other.year, other.month] == [year, month]
      end
      
      def nth_wday_in_month(n, which_wday)
        @date_time_value.nth_wday_in_month(n, which_wday, self)
      end
      
      def nth_wday_in_year(n, which_wday)
        @date_time_value.nth_wday_in_year(n, which_wday, self)
      end
      
      # Return the number of days in the month containing the receiver
      def days_in_month
        @date_time_value.days_in_month
      end

      # Return a DATE_TIME value representing the first second of the minute containing the receiver
      def start_of_minute
        change(:sec => 0)
      end

      # Return a DATE_TIME value representing the last second of the minute containing the receiver
      def end_of_minute
        change(:sec => 59)
      end

      # Return a DATE_TIME value representing the first second of the hour containing the receiver
      def start_of_hour
        change(:min => 0, :sec => 0)
      end

      # Return a DATE_TIME value representing the last second of the hour containing the receiver
      def end_of_hour
        change(:min => 59, :sec => 59)
      end

      # Return a DATE_TIME value representing the first second of the day containing the receiver
      def start_of_day
        change(:hour => 0, :min => 0, :sec => 0)
      end

      # Return a DATE_TIME value representing the last second of the day containing the receiver
      def end_of_day
        change(:hour => 23, :min => 59, :sec => 59)
      end
      
      # Return a Ruby Date representing the first day of the ISO week starting with wkst containing the receiver
      def start_of_week_with_wkst(wkst)
        @date_time_value.start_of_week_with_wkst(wkst)
      end

      # Return a DATE_TIME value representing the last second of the ISO week starting with wkst containing the receiver
      def end_of_week_with_wkst(wkst)
        date = at_start_of_week_with_wkst(wkst).advance(:days => 6).end_of_day
      end

      # Return a DATE_TIME value representing the first second of the month containing the receiver
      def start_of_month
        change(:day => 1, :hour => 0, :min => 0, :sec => 0)
      end

      # Return a DATE_TIME value representing the last second of the month containing the receiver
      def end_of_month
        change(:day => days_in_month, :hour => 23, :min => 59, :sec => 59)
      end

      # Return a DATE_TIME value representing the first second of the month containing the receiver
      def start_of_year
        change(:month => 1, :day => 1, :hour => 0, :min => 0, :sec => 0)
      end

      # Return a DATE_TIME value representing the last second of the month containing the receiver
      def end_of_year
        change(:month => 12, :day => 31, :hour => 23, :min => 59, :sec => 59)
      end

      # Return a DATE_TIME value representing the same time on the first day of the ISO year with weeks
      # starting on wkst containing the receiver
      def at_start_of_iso_year(wkst)
        start_of_year = @date_time_value.iso_year_start(wkst)
        change(:year => start_of_year.year, :month => start_of_year.month, :day => start_of_year.day)
      end

      # Return a DATE_TIME value representing the same time on the last day of the ISO year with weeks
      # starting on wkst containing the receiver
      def at_end_of_iso_year(wkst)
        num_weeks = @date_time_value.iso_weeks_in_year(wkst)
        at_start_of_iso_year(wkst).advance(:weeks => (num_weeks - 1), :days => 6)
      end

      # Return a DATE_TIME value representing the same time on the first day of the ISO year with weeks
      # starting on wkst after the ISO year containing the receiver
      def at_start_of_next_iso_year(wkst)
        num_weeks = @date_time_value.iso_weeks_in_year(wkst)
        at_start_of_iso_year(wkst).advance(:weeks => num_weeks)
      end

      # Return a DATE_TIME value representing the last second of the last day of the ISO year with weeks
      # starting on wkst containing the receiver
      def end_of_iso_year(wkst)
        at_end_of_iso_year(wkst).end_of_day
      end

      # Return a DATE-TIME representing the same time, on the same day of the month in month.
      # If the month of the receiver has more days than the target month the last day of the target month
      # will be used.
      def in_month(month)
        first = change(:day => 1, :month => month)
        first.change(:day => [first.days_in_month, day].min)
      end

      # Determine if the receiver and another object are equivalent RiCal::PropertyValue::DateTime instances
      def ==(other)
        if self.class === other
          self.value == other.value && self.visible_params == other.visible_params && self.tzid == other.tzid
        else
          super
        end
      end

      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration) # :nodoc:
        {:start => self, :end => (default_duration ? self + default_duration : nil)}
      end

      # Return the year (including the century)
      def year
        @date_time_value.year
      end

      # Return the month of the year (1..12)
      def month
        @date_time_value.month
      end

      # Return the day of the month
      def day
        @date_time_value.day
      end
      
      alias_method :mday, :day

      # Return the day of the week
      def wday
        @date_time_value.wday
      end

      # Return the hour
      def hour
        @date_time_value.hour
      end

      # Return the minute
      def min
        @date_time_value.min
      end
      
       # Return the second
      def sec
        @date_time_value.sec
      end


      # Return an RiCal::PropertyValue::DateTime representing the receiver.
      def to_ri_cal_date_time_value
        self
      end
      
      def iso_year_and_week_one_start(wkst) #:nodoc:
        @date_time_value.iso_year_and_week_one_start(wkst)
      end
      
      def iso_weeks_in_year(wkst)
        @date_time_value.iso_weeks_in_year(wkst)
      end

      # Return the "Natural' property value for the receover, in this case the receiver itself."
      def to_ri_cal_date_or_date_time_value
        self
      end

      # Return the Ruby DateTime representation of the receiver
      def to_datetime
        @date_time_value
      end

      # Returns a ruby DateTime object representing the receiver.
       def ruby_value
        to_datetime
      end

      alias_method :to_ri_cal_ruby_value, :ruby_value

      # Determine if the receiver has a local time zone, i.e. it is not a floating time or a UTC time
      def has_local_timezone?
        tzid && tzid != "UTC"
      end

      def add_date_times_to(required_timezones) #:nodoc:
        required_timezones.add_datetime(self) if has_local_timezone?
      end
    end
  end
end