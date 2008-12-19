class RiCal::PropertyValue
end

%w{
  text_value 
  array_value 
  integer_value 
  date_value 
  date_time_value 
  duration_value
  cal_address_value
  uri_value
  date_list_value
  recurrence_rule_value
  }.each do |sub|
    require File.expand_path(File.join(File.dirname(__FILE__), sub))
  end

module RiCal

  class PropertyValue

    attr_accessor :name, :params, :value
    def initialize(separated_line)
      self.name = separated_line[:name]
      self.params = separated_line[:params]
      self.value = separated_line[:value]
    end
    
    def self.date_or_date_time(separated_line)

      match = separated_line[:value].match(/(\d\d\d\d)(\d\d)(\d\d)((T?)((\d\d)(\d\d)(\d\d))(Z?))?/)
      raise Exception.new("Invalid date") unless match
      if match[5] == "T" # date-time
        time = Time.utc(match[1].to_i, match[2].to_i, match[3].to_i, match[7].to_i, match[8].to_i, match[9].to_i)
        parms = (separated_line[:params] ||{}).dup
        if match[10] == "Z"
          raise Exception.new("Invalid time, cannot combine Zulu with timezone reference") if parms[:tzid]
          parms[:tzid] = "UTC"
        end
        DateTimeValue.new(separated_line.merge(:value => time, :params => parms ))
      else
        date = Date.civil(match[1].to_i, match[2].to_i, match[3].to_i)
        DateValue.new(separated_line.merge(:value => date))
      end
    end
    

  end

end
