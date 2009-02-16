require 'date'
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

  # code stolen from ActiveSupport Gem
  unless  String.instance_methods.include?("camelize")
      def camelize
        self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
  end
end




class Date
  def to_ri_cal_date_time_value
    RiCal::DateValue.from_date(self)
  end
end

class DateTime
  def to_ri_cal_date_time_value
    RiCal::DateTimeValue.from_time(self)
  end
end

class Time
  def to_ri_cal_date_time_value
    RiCal::DateTimeValue.from_time(self)
  end
end