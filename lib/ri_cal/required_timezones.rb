module RiCal
  # RequireTimezones collects the timezones used by a given calendar component or set of calendar components
  # For each timezone we collect it's id, and the earliest and latest times which reference the zone
  class RequiredTimezones
    
    
    # A required timezone represents a single timezone and the earliest and latest times which reference it.
    class RequiredTimezone
      
      attr_reader :first_time, :last_time, :timezone
      
      def initialize(timezone)
        @timezone = timezone
      end
      
      def tzid
        @timezone.identifier
      end
      
      def add_datetime(date_time)
        if @first_time 
          @first_time = date_time if date_time < @first_time
        else
          @first_time = date_time
        end
        if @last_time 
          @last_time = date_time if date_time > @last_time
        else
          @last_time = date_time
        end
      end
    end
    
    def required_timezones
      @required_zones ||= {}
    end
    
    def required_zones
      required_timezones.values
    end
    
    def add_datetime(date_time)
      (required_timezones[date_time.tzid] ||= RequiredTimezone.new(date_time.timezone)).add_datetime(date_time)
    end
  end
end