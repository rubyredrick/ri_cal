module RiCal
  class Component
    class Timezone
      # A StandardPeriod is a TimezonePeriod during which daylight saving time is *not* in effect
      class StandardPeriod < TimezonePeriod #:nodoc: all

        def self.entity_name #:nodoc:
          "STANDARD"
        end
      end
    end
  end
end