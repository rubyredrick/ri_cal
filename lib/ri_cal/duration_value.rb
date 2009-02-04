require 'date'
module RiCal

  # rfc 2445 section 4.3.4 p 34
  class DurationValue < PropertyValue

    def self.convert(ruby_object)
      ruby_object.to_ri_cal_duration_value
    end
  end
end