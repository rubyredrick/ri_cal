require File.join(File.dirname(__FILE__), 'property_value')
module RiCal

  class DateTimeValue < PropertyValue

    def self.from_separated_line(line)
      if /T/.match(line[:value] || "")
        new(line)
      else
        DateValue.new(line)
      end
    end 

    def tzid
      params && params[:tzid]
    end
    
    def to_datetime
      value.to_datetime
    end
  end

end