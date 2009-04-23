module RiCal
  # PropertyValue provides common implementation of various RFC 2445 property value types
  class PropertyValue

    attr_accessor :params, :value
    def initialize(separated_line) # :nodoc:
      val = separated_line[:value]
      raise "Invalid property value #{val.inspect}" if val.kind_of?(String) && /^;/.match(val)
      self.params = separated_line[:params] || {}
      self.value = val
    end

    def self.date_or_date_time(separated_line) # :nodoc:
      match = separated_line[:value].match(/(\d\d\d\d)(\d\d)(\d\d)((T?)((\d\d)(\d\d)(\d\d))(Z?))?/)
      raise Exception.new("Invalid date") unless match
      if match[5] == "T" # date-time
        time = Time.utc(match[1].to_i, match[2].to_i, match[3].to_i, match[7].to_i, match[8].to_i, match[9].to_i)
        parms = (separated_line[:params] ||{}).dup
        if match[10] == "Z"
          raise Exception.new("Invalid time, cannot combine Zulu with timezone reference") if parms[:tzid]
          parms['TZID'] = "UTC"
        end
        PropertyValue::DateTime.new(separated_line.merge(:params => parms))
      else
        PropertyValue::Date.new(separated_line)
      end
    end

    def self.from_string(string) # :nodoc:
      new(:value => string)
    end
    
    # Determine if another object is equivalent to the receiver.
    def ==(o)
      if o.class == self.class
        equality_value == o.equality_value
      else
        super
      end
    end
    
    def equality_value
      value
    end
    
    def visible_params # :nodoc:
      params
    end

    # Return a string representing the receiver in RFC 2445 format
    def to_s
      if visible_params && !visible_params.empty?
        "#{visible_params.map {|key, val| ";#{key}=#{val}"}}:#{value}"
      else
        ":#{value}"
      end
    end
    
    # return the ruby value
    def ruby_value
      self.value
    end
  end
end

Dir[File.dirname(__FILE__) + "/property_value/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require path
end
