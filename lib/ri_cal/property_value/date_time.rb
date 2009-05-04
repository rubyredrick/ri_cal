require 'date'
module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar CalAddress property value
    # which is defined in RFC 2445 section 4.3.5 pp 35-37
    class DateTime < PropertyValue
      
      Dir[File.dirname(__FILE__) + "/date_time/*.rb"].sort.each do |path|
        require path
      end
      
      include Comparable
      include AdditiveMethods
      include TimezoneSupport
      include TimeMachine

      # def initialize(timezone_finder, options={}) #:nodoc:
      #   super(timezone_finder ? timezone_finder : Calendar.new, options)
      # end
      # 
      def self.or_date(parent, line) # :nodoc:
        if /T/.match(line[:value] || "")
          new(parent, line)
        else
          PropertyValue::Date.new(parent, line)
        end
      end

      def self.default_tzid # :nodoc:
        @default_tzid ||= "UTC"
      end

      def self.params_for_tzid(tzid) #:nodoc:
        if tzid == FloatingTimezone
          {}
        else
          {'TZID' => tzid}
        end
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
      def self.object_tzid(object)
        activesupport_time = object.acts_like_time? rescue nil
        time_zone = activesupport_time && object.time_zone rescue nil
        time_zone && (time_zone.respond_to?(:tzinfo) ? time_zone.tzinfo  : time_zone).identifier
      end

      def self.convert(timezone_finder, ruby_object) # :nodoc:
        convert_with_tzid_or_nil(timezone_finder, ruby_object) || ruby_object.to_ri_cal_date_or_date_time_value.for_parent(timezone_finder)
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
        convert_with_tzid_or_nil(nil, time_or_date_time) || 
        new(nil, :value => time_or_date_time.strftime("%Y%m%dT%H%M%S"), :params => default_tzid_hash)
      end

      def self.convert_with_tzid_or_nil(timezone_finder, ruby_object) # :nodoc:
        tzid = self.object_tzid(ruby_object)
        if tzid
          new(
          timezone_finder,
          :params => params_for_tzid(tzid),
          :value => ruby_object.strftime("%Y%m%d%H%M%S")
          )
        else
          nil
        end
      end

      def self.from_string(string) # :nodoc:
        if string.match(/Z$/)
          new(nil, :value => string, :tzid => 'UTC')
        else
          new(nil, :value => string)
        end
      end

      def for_parent(parent)
        if timezone_finder.nil?
          @timezone_finder = parent
          self
        elsif parent == timezone_finder
          self
        else
          DateTime.new(parent, :value => @date_time_value, :params => params, :tzid => tzid)
        end
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
          @tzid = params_timezone
        end
      end

      # Compare the receiver with another object which must respond to the to_datetime message
      # The comparison is done using the Ruby DateTime representations of the two objects
      def <=>(other)
       @date_time_value <=> other.to_datetime
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

      def add_date_times_to(required_timezones) #:nodoc:
        required_timezones.add_datetime(self, tzid) if has_local_timezone?
      end
    end
  end
end