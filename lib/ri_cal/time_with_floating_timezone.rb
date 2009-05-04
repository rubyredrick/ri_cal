module RiCal
  # FloatingTimezone represents the 'time zone' for a time or date time with no timezone
  # Times with floating timezones are always interpreted in the timezone of the observer
  class FloatingTimezone
    
    def self.identifier
      nil
    end
    
    def self.tzinfo_timezone
      nil
    end
    
    # Return the time unchanged
    def self.utc_to_local(time)
      time.with_floating_timezone.to_ri_cal_date_time_value
    end

    # Return the time unchanged
    def self.local_to_utc(time)
      time.with_floating_timezone.to_ri_cal_date_time_value
    end
  end
  
  class TimeWithFloatingTimezone #:nodoc:
    def initialize(time) #:nodoc:
      @time = time
    end

    def acts_like_time? #:nodoc:
      true
    end

    def time_zone
      FloatingTimezone #:nodoc:
    end

    def strftime(format) #:nodoc:
      @time.strftime(format)
    end
    
    def with_floating_timezone #:nodoc:
      self
    end

    def to_ri_cal_date_time_value #:nodoc:
      ::RiCal::PropertyValue::DateTime.new(nil, :value => @time, :params => {'TZID' => nil})
    end

    alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_time_value #:nodoc:
    
    def method_missing(selector, *args) #:nodoc:
      @time.send(selector, *args)
    end
  end
end