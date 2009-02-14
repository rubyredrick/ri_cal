require 'date'
module RiCal
  
  # rfc 2445 section 4.3.4 p 34
  class DateValue < PropertyValue
    def value
      if @date_time_value
        @date_time_value.strftime("%Y%m%d")
      else
        nil
      end
    end 
    
    def value=(val)
      case val
      when nil
        @date_time_value = nil
      when String
        @date_time_value = DateTime.parse(val)
      when Time, Date, DateTime
        @date_time_value = DateTime.parse(val.strftime("%Y%m%d"))
      end
    end
    
    def ruby_value
      Date.parse(@date_time_value.strftime("%Y%m%d"))
    end
    
    def to_ri_cal_date_time_value
      DateTimeValue.new(:value => @date_time_value)
    end    
    
    def to_ri_cal_date_value
      self
    end    
    
    def duration_until(end_time)
      #TODO: this should calculate a duration
      #  if end_time is nil => nil
      #  otherwise convert end_time to a DateValue and compute the difference
      end_time
    end
    
    
  end

end