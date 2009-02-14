module RiCal
  
  class PropertyValue

    attr_accessor :params, :value
    def initialize(separated_line)
      val = separated_line[:value]
       raise "Invalid property value #{val.inspect}" if val.kind_of?(String) && /^;/.match(val)
      self.params = separated_line[:params]
      self.value = val
    end
    
    def self.date_or_date_time(separated_line)
      match = separated_line[:value].match(/(\d\d\d\d)(\d\d)(\d\d)((T?)((\d\d)(\d\d)(\d\d))(Z?))?/)
      raise Exception.new("Invalid date") unless match
      if match[5] == "T" # date-time
        time = Time.utc(match[1].to_i, match[2].to_i, match[3].to_i, match[7].to_i, match[8].to_i, match[9].to_i)
        parms = (separated_line[:params] ||{}).dup
        if match[10] == "Z"
          raise Exception.new("Invalid time, cannot combine Zulu with timezone reference") if parms[:tzid]
          parms['TZID'] = "UTC"
        end
        DateTimeValue.new(separated_line.merge(:params => parms))
      else
        DateValue.new(separated_line)
      end
    end
    
    def self.from_string(string)
      new(:value => string)
    end

  end

end
