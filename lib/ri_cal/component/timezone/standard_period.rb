#- ©2009 Rick DeNatale
#- All rights reserved

module RiCal
  class Component
    class Timezone
      # A StandardPeriod is a TimezonePeriod during which daylight saving time is *not* in effect
      class StandardPeriod < TimezonePeriod #:nodoc: all

        def self.entity_name #:nodoc:
          "STANDARD"
        end
        
        def dst?
          false
        end
        
        def ambiguous_local?(time)
          [time.year, time.month, time.day] == [dtstart.year, dtstart.month, dtstart.day]
        end
      end
    end
  end
end