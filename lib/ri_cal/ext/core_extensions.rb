class Object
  def to_rfc2445_string
    to_s
  end
end

class Array
  def to_rfc2445_string
    join(",")
  end
end

class String
  def to_ri_cal_date_time_value
    RiCal::DateTimeValue.from_string(self)
  end
  
  def to_ri_cal_duration_value
    RiCal::DurationValue.from_string(self)
  end
end