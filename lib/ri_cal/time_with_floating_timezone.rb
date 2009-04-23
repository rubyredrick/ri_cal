module RiCal

  class FloatingTimezone
    def self.utc_to_local(time)
      time.with_floating_timezone.to_ri_cal_date_time_value
    end

    def local_to_utc(time)
      time.with_floating_timezone.to_ri_cal_date_time_value
    end
  end
  class TimeWithFloatingTimezone
    def initialize(time)
      @time = time
    end

    def acts_like_time?
      true
    end

    def time_zone
      FloatingTimezone
    end

    def strftime(format)
      @time.strftime(format)
    end
    
    def with_floating_timezone
      self
    end

    def to_ri_cal_date_time_value
      ::RiCal::PropertyValue::DateTime.convert(self)
    end

    alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_time_value
    
    def method_missing(selector, *args)
      @time.send(selector, *args)
    end
  end
end