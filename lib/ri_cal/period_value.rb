module RiCal

  # rfc 2445 section 4.3.9 p 39
  class PeriodValue < PropertyValue
    
    attr_accessor :dtstart, :dtend, :duration

    def value=(string)
      starter, terminator = *string.split("/")
      self.dtstart = DateTimeValue.new(:value => starter)
      if /P/ =~ terminator
        self.duration = DurationValue.new(:value => terminator)
        self.dtend = dtstart + duration
      else
        self.dtend   = DateTimeValue.new(:value => terminator)
        self.duration = DurationValue.from_datetimes(dtstart.to_datetime, dtend.to_datetime)        
      end
    end

    def self.convert(ruby_object)
      ruby_object.to_ri_cal_period_value
    end
    
    def to_ri_cal_period_value
      self
    end
    
    # TODO: consider if this should be a period rather than a hash
    def occurrence_hash(default_duration)
      {:start => self, :end => (default_duration ? self + default_duration : nil)}
    end
    
  end
end