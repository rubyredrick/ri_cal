module RiCal
  class Component
    class Timezone
      # A DaylightPeriod is a TimezonePeriod during which daylight saving time *is* in effect
      class DaylightPeriod < TimezonePeriod #:nodoc: all

        def self.entity_name #:nodoc:
          "DAYLIGHT"
        end
      end
    end
  end
end