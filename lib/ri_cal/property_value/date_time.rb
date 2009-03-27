require 'date'
module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar CalAddress property value
    # which is defined in RFC 2445 section 4.3.5 pp 35-37
    class DateTime < PropertyValue

      def self.debug # :nodoc:
        @debug
      end

      def self.default_tzid # :nodoc:
        @default_tzid ||= "UTC"
      end

      # Set the default tzid to be used when instantiating an instance from a ruby object
      # see RiCal::PropertyValue::DateTime.from_time
      # == Parameter
      # value:: A string value to be used for the default tzid, a value of 'none' will cause
      # values with NO timezone to be produced, these are interpreted by iCalendar as floating times
      # i.e. they are interpreted in the timezone of each client. Floating times are typically used
      # to represent events which are 'repeated' in the various time zones, like the first hour of the year.
      def self.default_tzid=(value)
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

      def self.from_separated_line(line) # :nodoc:
        if /T/.match(line[:value] || "")
          new(line)
        else
          PropertyValue::Date.new(line)
        end
      end

      # Return an RiCal::PropertyValue::DateTime representing the receiver
      def to_ri_cal_date_time_value
        self
      end

      #  if end_time is nil => nil
      #  otherwise convert end_time to a DateTime and compute the difference
      def duration_until(end_time) # :nodoc:
        end_time  && RiCal::PropertyValue::Duration.from_datetimes(to_datetime, end_time.to_datetime)
      end

      # Double-dispatch method for subtraction.
      def subtract_from_date_time_value(dtvalue)
        RiCal::PropertyValue::Duration.from_datetimes(to_datetime,dtvalue.to_datetime)
      end

      # Double-dispatch method for addition.
      def add_to_date_time_value(date_time_value)
        raise ArgumentError.new("Cannot add #{date_time_value} to #{self}")
      end

      # Return the difference between the receiver and other
      # == parameter
      # other:: either a RiCal::PropertyValue::Duration or a RiCal::PropertyValue::DateTime
      #
      # If other is a Duration, the result will be a DateTime, if it is a DateTime the result will be a Duration
      def -(other)
        other.subtract_from_date_time_value(self)
      end

      # Return the sum of the receiver and other
      # == parameter
      # other:: a RiCal::PropertyValue::Duration
      #
      # The result will be an RiCal::PropertyValue::Duration
      def +(other)
        other.add_to_date_time_value(self)
      end

      def inspect # :nodoc:
        "ri_cal:#{@value}::#{@date_time_value}#{params ? " #{params.inspect}" : ""}"
      end

      # Returns the value of the reciever as an RFC 2445 iCalendar string
      def value
        if @date_time_value
          @date_time_value.strftime("%Y%m%dT%H%M%S#{tzid == "UTC" ? "Z" : ""}")
        else
          nil
        end
      end 

      def value=(val) # :nodoc:
        case val
        when nil
          @date_time_value = nil
        when String
          @params['TZID'] = 'UTC' if val =~/Z/
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

      def self.convert(ruby_object) # :nodoc:
        time_zone = object_time_zone(ruby_object)
        if time_zone
          new(
          :params => {'TZID' => time_zone.identifier, 'X-RICAL-TZSOURCE' => 'TZINFO'}, 
          :value => ruby_object.strftime("%Y%m%d%H%M%S")
          )
        else
          ruby_object.to_ri_cal_date_time_value
        end
      end

      def self.from_string(string) # :nodoc:
        new(:value => string, :params => default_tzid_hash)
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
          new(:value => time_or_date_time.strftime("%Y%m%dT%H%M%S"), :params => default_tzid_hash)
        end
      end

      # Return the timezone id of the receiver, or nil if it is a floating time
      def tzid
        params && params['TZID']
      end
      
      def visible_params # :nodoc:
        if tzid == "UTC"
          new_hash = params.dup.delete('tzid')
          new_hash
        else
          params
        end
      end

      # Return the Ruby DateTime representation of the receiver
      def to_datetime
        @date_time_value
      end
      
      # Used by RiCal specs - returns a Ruby DateTime
      def to_ri_cal_ruby_value
        to_datetime
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
        PropertyValue::DateTime.new(:value => compute_advance(@date_time_value, options), :params =>(params ? params.dup : nil) )
      end

      def change(options) # :nodoc:
        PropertyValue::DateTime.new(:value => compute_change(@date_time_value, options), :params => (params ? params.dup : nil) )
      end
      
      def self.civil(year, month, day, hour, min, sec, offset, start, params)
        PropertyValue::DateTime.new(
           :value => ::DateTime.civil(year, month, day, hour, min, sec, offset, start),
           :params =>(params ? params.dup : nil)
        )
      end
      
      def change_sec(new_sec)
        PropertyValue::DateTime.civil(self.year, self.month, self.day, self.hour, self.min, sec, self.offset, self.start, params)
      end

      def change_min(new_min)
        PropertyValue::DateTime.civil(self.year, self.month, self.day, self.hour, new_min, self.sec, self.offset, self.start, params)
      end
      
      def change_hour(new_hour)
        PropertyValue::DateTime.civil(self.year, self.month, self.day, new_hour, self.min, self.sec, self.offset, self.start, params)
      end
      
      def change_day(new_day)
        PropertyValue::DateTime.civil(self.year, self.month, new_day, self.hour, self.min, self.sec, self.offset, self.start, params)
      end
      
      def change_month(new_month)
        PropertyValue::DateTime.civil(self.year, new_month, self.day, self.hour, self.min, self.sec, self.offset, self.start, params)
      end
      
      def change_year(new_year)
        PropertyValue::DateTime.civil(new_year, self.month, self.day, self.hour, self.min, self.sec, self.offset, self.start, params)
      end
      
      # Compare the receiver with another object which must respond to the to_datetime message
      # The comparison is done using the Ruby DateTime representations of the two objects
      def <=>(other)
        @date_time_value <=> other.to_datetime
      end
      
      def in_week_starting?(date)
        wkst_jd = date.jd
        @date_time_value.jd.between?(wkst_jd, wkst_jd + 6)
      end
      
      def at_start_of_week_with_wkst(wkst)
        date = @date_time_value.start_of_week_with_wkst(wkst)
        change(:year => date.year, :month => date.month, :day => date.day)
      end
      
      def in_same_month_as?(other)
        [other.year, other.month] == [year, month]
      end

      # Determine if the receiver and another object are equivalent RiCal::PropertyValue::DateTime instances
      def ==(other)
        if self.class === other
          self.value == other.value && self.params == other.params
        else
          super
        end
      end

      # TODO: consider if this should be a period rather than a hash    
      def occurrence_hash(default_duration) # :nodoc:
        {:start => self, :end => (default_duration ? self + default_duration : nil)}
      end
      
      def year
        @date_time_value.year
      end
      
      def month
        @date_time_value.month
      end
      
      def day
        @date_time_value.day
      end

      # Delegate unknown messages to the wrappered DateTime instance.
      # TODO: Is this really necessary?
      def method_missing(selector, *args)
        @date_time_value.send(selector, *args)
      end
    end
  end
end