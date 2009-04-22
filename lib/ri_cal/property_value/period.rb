module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar Period property value
    # which is defined in 
    # rfc 2445 section 4.3.9 p 39
    class Period < PropertyValue

      attr_accessor :dtstart, :dtend, :duration

      def value=(string) # :nodoc:
        starter, terminator = *string.split("/")
        self.dtstart = PropertyValue::DateTime.new(:value => starter)
        if /P/ =~ terminator
          self.duration = PropertyValue::Duration.new(:value => terminator)
          self.dtend = dtstart + duration
        else
          self.dtend   = PropertyValue::DateTime.new(:value => terminator)
          self.duration = PropertyValue::Duration.from_datetimes(dtstart.to_datetime, dtend.to_datetime)        
        end
      end

      def self.convert(ruby_object) # :nodoc:
        ruby_object.to_ri_cal_period_value
      end

      # return the receiver
      def to_ri_cal_period_value
        self
      end

      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration) # :nodoc:
        {:start => self, :end => (default_duration ? self + default_duration : nil)}
      end

      def add_date_times_to(required_timezones)
        dtstart.add_date_times_to(required_timezones)
        dtend.add_date_times_to(required_timezones)
      end
    end
  end
end